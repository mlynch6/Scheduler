require 'spec_helper'

describe "Location Pages:" do
	subject { page }
	
  describe "index" do
  	before(:each) do
  		visit locations_path
  	end
  	
		context "page" do
	    it { should have_selector('title', text: 'All Locations') }
	    it { should have_selector('h1', text: 'All Locations') }
	    
	    it "has a 'New' link" do
	    	should have_link('New', href: new_location_path)
	    end
	  end
    
    context "without records" do
    	before(:all) { Location.delete_all }
    	
    	it "shows 'No Records' message" do
    		should have_selector('div.alert', text: "No records found")
    	end

			it "shows NO records" do
				should_not have_selector('td')
			end
    	
    	it "has NO pagination" do
	    	should_not have_selector('div.pagination')
	    end
    end
    
    context "with records" do
    	before(:all) do
    		31.times { FactoryGirl.create(:location) }
    	end
    	after(:all)  { Location.delete_all }
    	
    	it "lists each location" do
    		Location.paginate(page: 1).each do |location|
    			should have_selector('td', text: location.name)
    		end
    	end
    	
    	it "has pagination" do
	    	should have_selector('div.pagination')
	    end
	    
	    it "has an 'Edit' link" do
	    	should have_link('Edit', href: edit_location_path(Location.first))
	    end
	    
	    it "has a 'Delete' link" do
	    	should have_link('Delete', href: location_path(Location.first))
	    end
    end
    
    context "filters" do
    	before {
    		FactoryGirl.create(:location)
    		FactoryGirl.create(:location_inactive)
    	}
	    
	    describe "has 'Active' filter that shows only active records" do
	    	before { click_link 'Active' }
	    	it { should_not have_selector('td', text: 'Inactive') }
	    end
	    
	    describe "has 'Inactive' filter that shows only inactive records" do
	    	before { click_link 'Inactive' }
	    	it { should_not have_selector('td', text: 'Active') }
	    end
    end
  end
  
  describe "destroy" do
  	before do
  		FactoryGirl.create(:location)
  		visit locations_path
  	end
  			
    it "deletes the record" do
    	expect { click_link 'Delete' }.to change(Location, :count).by(-1)
    end
		  	
  	describe "shows success message" do
  		before { click_link 'Delete' }
			it { should have_selector('div.alert-success') }
    end
	    
    describe "redirects to locations#index" do
    	before { click_link 'Delete' }
			it { should have_selector('h1', text: 'All Locations') }
		end
  end
  
  describe "new" do
  	let(:submit) { "Create" }
  	before do
  		visit new_location_path
  	end
  	
  	context "page" do
	    it { should have_selector('title', text: 'New Location') }
	    it { should have_selector('h1', text: 'New Location') }
	  end
    
    context "with invalid info" do   	
    	it "does NOT create a Location" do
    		expect { click_button submit }.not_to change(Location, :count)
    	end
    	
    	describe "shows error message" do
    		before { click_button submit }
    		it { should have_selector('div.alert-error') }
    	end
    end
    
    context "with valid info" do
    	let(:new_name) { "New Studio" }
    	before do
    		fill_in "Name", with: new_name
    	end
    	
    	it "creates a Location"do
    		expect { click_button submit }.to change(Location, :count).by(1)
    	end
    	
    	describe "shows success message" do
    		before { click_button submit }
    		it { should have_selector('div.alert-success') }
    	end
    	
    	describe "redirects to Location#index" do
    		before { click_button submit }
    		it { should have_selector('title', text: 'All Locations') }
    	end
    end
  end
  
  describe "edit" do
  	let(:location) { FactoryGirl.create(:location) }
  	let(:submit) { "Update" }
  	before do
  		visit edit_location_path(location)
  	end
  	
  	context "page" do
	    it { should have_selector('title', text: 'Edit Location') }
	    it { should have_selector('h1', text: 'Edit Location') }
    end
  	
  	context "with invalid URL" do
  		#before { edit_location_path(0) }

  		it "shows error message" do
  			pending
	    	#should have_selector('div.alert-error')
	    end
    	
  		it "redirects to locations#index" do
  			pending
    		should have_selector('title', text: 'All Locations')
    	end
  	end
    
    context "with invalid info" do
			before do
    		fill_in "Name", with: ""
    		click_button submit 
    	end
    		
    	it "shows error message" do
    		should have_selector('div.alert-error')
    	end
    end
    
    context "with valid info" do
    	let(:new_name) { "Updated Name" }
    	before do
    		fill_in "Name", with: new_name
    		select "Inactive", from: "Status"
    		click_button submit 
    	end
    	
    	it "shows success message" do
    		should have_selector('div.alert-success')
    	end
    	
    	it "updates the record" do
    		location.reload.name.should == new_name
    		location.reload.active.should be_false
    	end
    	
    	describe "redirects to location#index" do
    		it { should have_selector('title', text: 'All Locations') }
    	end
    end
  end
end
