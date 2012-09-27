require 'spec_helper'

describe "Piece Pages:" do
	subject { page }
	
  describe "index" do
  	before(:each) do
  		visit pieces_path
  	end
  	
		context "page" do
	    it { should have_selector('title', text: 'All Pieces') }
	    it { should have_selector('h1', text: 'All Pieces') }
	    
	    it "has a 'New' link" do
	    	should have_link('New', href: new_piece_path)
	    end
	  end
    
    context "without records" do
    	before(:all) { Piece.delete_all }
    	
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
    		31.times { FactoryGirl.create(:piece) }
    	end
    	after(:all)  { Piece.delete_all }
    	
    	it "lists each piece" do
    		Piece.paginate(page: 1).each do |piece|
    			should have_selector('td', text: piece.name)
    		end
    	end
    	
    	it "has pagination" do
	    	should have_selector('div.pagination')
	    end
	    
	    it "has a 'Show' link on name" do
	    	should have_link(Piece.first.name, href: piece_scenes_path(Piece.first))
	    end
	    
	    it "has an 'Edit' link" do
	    	should have_link('Edit', href: edit_piece_path(Piece.first))
	    end
	    
	    it "has a 'Delete' link" do
	    	should have_link('Delete', href: piece_path(Piece.first))
	    end
    end
    
    context "filters" do
    	it "has an 'Active' filter" do
	    	should have_link('Active', href: pieces_path(:status => 'active'))
	    end
	    
	    it "shows only active records for the 'Active' filter" do
	    	pending
	    end
	    
	    it "has an 'Inactive' filter" do
	    	should have_link('Inactive', href: pieces_path(:status => 'inactive'))
	    end
	    
	    it "shows only inactive records for the 'Inactive' filter" do
	    	pending
	    end
	    
	    it "has an 'All' filter" do
	    	should have_link('All', href: pieces_path)
	    end
	    
	    it "shows active and inactive records for the 'All' filter" do
	    	pending
	    end
    end
  end
  
  describe "destroy" do
  	before do
  		FactoryGirl.create(:piece)
  		visit pieces_path
  	end
  			
    it "deletes a piece" do
    	expect { click_link 'Delete' }.to change(Piece, :count).by(-1)
    end
		  	
  	describe "shows success message" do
  		before { click_link 'Delete' }
			it { should have_selector('div.alert-success') }
    end
	    
    describe "redirects to pieces#index" do
    	before { click_link 'Delete' }
			it { should have_selector('h1', text: 'All Pieces') }
		end
  end
  
  describe "new" do
  	let(:submit) { "Create" }
  	before do
  		visit new_piece_path
  	end
  	
  	context "page" do
	    it { should have_selector('title', text: 'New Piece') }
	    it { should have_selector('h1', text: 'New Piece') }
	    
		  context "Scenes section" do
		  	it "has a Scenes section" do
		    	should have_content('Scenes')
		    end
		    
		    it "has 'Add Scene' button" do
		    	should have_link('Add Scene')
		    end
		    
		    it "clicking 'Add Scene' button adds new row of form inputs" do
		    	pending
		    end
		  end
		  
		  context "Roles section" do
		  	it "has a Roles section" do
		    	should have_content('Roles')
		    end
		    
		    it "has 'Add Role' button" do
		    	should have_link('Add Role')
		    end
		    
		    it "clicking 'Add Role' button adds new row of form inputs" do
		    	pending
		    end
		  end
	  end
    
    context "with invalid info" do   	
    	it "does NOT create a piece" do
    		expect { click_button submit }.not_to change(Piece, :count)
    	end
    	
    	describe "shows error message" do
    		before { click_button submit }
    		it { should have_selector('div.alert-error') }
    	end
    end
    
    context "with valid info" do
    	let(:new_name) { "New Name" }
    	before do
    		fill_in "Name", with: new_name
    		fill_in "piece_scenes_attributes_0_name", with: "Scene 1"
    		fill_in "piece_scenes_attributes_0_order_num", with: "1"
    		fill_in "piece_scenes_attributes_1_name", with: "Scene 2"
    		fill_in "piece_scenes_attributes_1_order_num", with: "2"
    		fill_in "piece_roles_attributes_0_name", with: "Role 1"
    		fill_in "piece_roles_attributes_1_name", with: "Role 2"
    	end
    	
    	it "creates a piece"do
    		expect { click_button submit }.to change(Piece, :count).by(1)
    	end
    	
    	it "creates associated scenes" do
    		expect { click_button submit }.to change(Scene, :count).by(2)
    	end
    	
    	it "creates associated roles" do
    		expect { click_button submit }.to change(Role, :count).by(2)
    	end
    	
    	describe "shows success message" do
    		before { click_button submit }
    		it { should have_selector('div.alert-success') }
    	end
    	
    	describe "redirects to piece#show" do
    		before { click_button submit }
    		it { should have_selector('title', text: new_name) }
    		it { should have_selector('title', text: 'Performances') }
    	end
    end
  end
  
  describe "edit" do
  	let(:piece) { FactoryGirl.create(:piece) }
  	let(:submit) { "Update" }
  	before do
  		visit edit_piece_path(piece)
  	end
  	
  	context "page" do
	    it { should have_selector('title', text: 'Edit Piece') }
	    it { should have_selector('h1', text: 'Edit Piece') }
    end
  	
  	context "with invalid URL" do
  		describe "having invalid piece ID" do
  			#before { edit_piece_path(0) }
  			it "redirects to pieces#index" do
    			pending
    			#should have_selector('title', text: 'All Pieces')
    		end
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
    		piece.reload.name.should == new_name
    		piece.reload.active.should be_false
    	end
    	
    	describe "redirects to piece#show" do
    		it { should have_selector('title', text: new_name) }
    		it { should have_selector('title', text: 'Performances') }
    	end
    end
  end
  
	describe "show" do
		let(:piece) { FactoryGirl.create(:piece) }
  	before do
  		visit piece_path(piece)
  	end
  	
  	context "page" do
	    it { should have_selector('title', text: piece.name) }
	    it { should have_selector('title', text: 'Performances') }
	    it { should have_selector('h1', text: piece.name) }
	    
	    describe "has sub navigation" do
		    it "has a 'Performances' link" do
	    		should have_link('Performances', href: piece_path(piece))
	    	end
	    	
	    	it "has a 'Scenes' link" do
	    		should have_link('Scenes', href: pieces_scenes_path(piece))
	    	end
	    	
	    	it "has a 'Roles' link" do
	    		should have_link('Roles', href: pieces_roles_path(piece))
	    	end
	    end
    end
    
    context "without Performance records" do
    	before(:all) { Piece.performances.delete_all }
    	
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
    
    context "with Performance records" do
    	before(:all) do
    		31.times { FactoryGirl.create(:performance, piece: piece) }
    	end
    	after(:all)  { Piece.performances.delete_all }
    	
    	it "lists each performance" do
    		Piece.performances.paginate(page: 1).each do |perf|
    			should have_selector('td', text: perf.name)
    		end
    	end
    	
    	it "has pagination" do
	    	should have_selector('div.pagination')
	    end
	    
	    it "has 'Show' link on performance name" do
	    	should have_link(Piece.performances.first.name, href: performances_path(Piece.performances.first))
	    end
    end
	end
end
