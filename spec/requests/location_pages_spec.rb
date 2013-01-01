require 'spec_helper'

describe "Location Pages:" do
	subject { page }
  
  context "#index" do
		it "without records" do
			log_in
			current_account.locations.delete_all
	  	visit locations_path
	  	
	  	should have_selector('title', text: 'All Locations')
		  should have_selector('h1', text: 'All Locations')
	  	
	    should have_selector('div.alert', text: "No records found")
			should_not have_selector('td')
			should_not have_selector('div.pagination')
		end
	  
		it "lists records" do
			log_in
			4.times { FactoryGirl.create(:location, account: current_account) }
			visit locations_path(per_page: 3)
	
			should have_selector('div.pagination')
			Location.active.paginate(page: 1, per_page: 3).each do |location|
				should have_selector('td', text: location.name)
				should have_link('Edit', href: edit_location_path(location))
				should have_link('Delete', href: location_path(location))
	    end
		end
		
		it "doesn't have links for Employee" do
			log_in_employee
			FactoryGirl.create(:location, account: current_account)
			visit locations_path
	
			should_not have_link('New')
			should_not have_link('Edit')
			should_not have_link('Delete')
		end
		
		it "has links for Administrator" do
			log_in_admin
			FactoryGirl.create(:location, account: current_account)
			visit locations_path
	
			should have_link('New')
			should have_link('Edit')
			should_not have_link('Delete')
		end
		
		it "has active filter" do
			log_in
	  	FactoryGirl.create(:location, account: current_account)
			FactoryGirl.create(:location_inactive, account: current_account)
	  	visit locations_path
	  	click_link 'Active'
	  	
			should have_selector('td', text: 'Active')
			should_not have_selector('td', text: 'Inactive')
		end
	 
		it "has inactive filter" do
			log_in
	  	FactoryGirl.create(:location, account: current_account)
			FactoryGirl.create(:location_inactive, account: current_account)
	  	visit locations_path
	  	click_link 'Inactive'
	  	
			should have_selector('td', text: 'Inactive')
			should_not have_selector('td', text: 'Active')
		end
	end

	context "#new" do
		it "record with error" do
			log_in
			visit locations_path
	  	click_link 'New'
	
			should have_selector('title', text: 'New Location')
			should have_selector('h1', text: 'New Location')
	
			expect { click_button 'Create' }.not_to change(Location, :count)
			should have_selector('div.alert-error')
		end
	
		it "record with valid info" do
			log_in
			visit locations_path
	  	click_link 'New'
	  	new_name = Faker::Lorem.word
			fill_in "Name", with: new_name
			click_button 'Create'
	
			#expect { click_button 'Create' }.to change(Location, :count).by(1)
			should have_selector('div.alert-success')
			should have_selector('title', text: 'All Locations')
			should have_content(new_name)
		end
	end

	context "#edit" do
	  it "record with error" do
	  	log_in
	  	location = FactoryGirl.create(:location, account: current_account)
	  	visit edit_location_path(location)
	  	fill_in "Name", with: ""
	  	click_button 'Update'
	
			should have_selector('title', text: 'Edit Location')
			should have_selector('h1', text: 'Edit Location')
			should have_selector('div.alert-error')
		end
	
		it "with bad record in URL" do
			pending
			log_in
			edit_location_path(0)
	
			should have_content('Record Not Found')
			should have_selector('div.alert-error', text: 'Record Not Found')
			should have_selector('title', text: 'All Locations')
		end
	 
		it "with valid info" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			new_name = Faker::Lorem.word
			visit locations_path
			click_link "edit_#{location.id}"
			fill_in "Name", with: new_name
			select "Inactive", from: "Status"
			click_button 'Update'
	
			should have_selector('div.alert-success')
			location.reload.name.should == new_name
			location.reload.active.should be_false
			should have_selector('title', text: 'All Locations')
		end
	end
	
	it "destroy record", :js => true, :driver => :webkit do
		pending "need to test with js Delete confirmation"
  	log_in
		location = FactoryGirl.create(:location, account: current_account)
		visit locations_path
		click_link "delete_#{location.id}"
		
		#expect { click_link "delete_#{location.id}" }.to change(Location, :count).by(-1)
		should have_selector('div.alert-success')
		should have_selector('title', text: 'All Locations')
		should_not have_content(location.name)
	end
end
