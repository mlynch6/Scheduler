require 'spec_helper'

describe "Role Pages:" do
	subject { page }
  let(:piece) { FactoryGirl.create(:piece) }
  
  describe "index" do
  	before do
  		visit piece_roles_path(piece)
  	end
  	
		context "page" do
			it { should have_selector('title', text: piece.name) }
	    it { should have_selector('title', text: 'Roles') }
	    it { should have_selector('h1', text: piece.name) }
	    
	    it "has a 'New' link" do
	    	should have_link('New', href: new_piece_role_path(piece))
	    end
	    
			describe "has sub navigation" do
		    it "has a 'Performances' link" do
	    		should have_link('Performances', href: piece_path(piece))
	    	end
	    	
	    	it "has a 'Scenes' link" do
	    		should have_link('Scenes', href: piece_scenes_path(piece))
	    	end
	    	
	    	it "has a 'Roles' link" do
	    		should have_link('Roles', href: piece_roles_path(piece))
	    	end
	    end
	  end
    
		context "without records" do
			before(:all) { piece.roles.delete_all }
    	
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
    		31.times { FactoryGirl.create(:role, piece: piece) }
    	end
    	after(:all)  { piece.roles.delete_all }
    	
    	it "lists each role" do
    		piece.roles.paginate(page: 1).each do |role|
    			should have_selector('td', text: role.name)
    		end
    	end
    	
    	it "has pagination" do
	    	should have_selector('div.pagination')
	    end
	    
	    it "has an 'Edit' link" do
	    	should have_link('Edit', href: edit_piece_role_path(piece, piece.roles.first))
	    end
	    
	    it "has a 'Delete' link" do
	    	should have_link('Delete', href: piece_role_path(piece, piece.roles.first))
	    end
    end
  end
  
  describe "destroy" do
  	before do
  		FactoryGirl.create(:role, piece: piece)
  		visit piece_roles_path(piece)
  	end
  			
    it "deletes a role" do
    	expect { click_link 'Delete' }.to change(Role, :count).by(-1)
    end
		  	
  	describe "shows success message" do
  		before { click_link 'Delete' }
			it { should have_selector('div.alert-success') }
    end
	    
    describe "redirects to role index" do
    	before { click_link 'Delete' }
			it { should have_selector('title', text: 'Roles') }
		end
  end
  
  describe "new" do
  	let(:submit) { "Create" }
  	before do
  		visit new_piece_role_path(piece)
  	end
  	
  	context "page" do
	    it { should have_selector('title', text: 'New Role') }
	    it { should have_selector('h1', text: piece.name) }
	    it { should have_selector('legend', text: 'New Role') }
	  end
    
    context "with invalid info" do   	
    	it "does NOT create a role" do
    		expect { click_button submit }.not_to change(Role, :count)
    	end
    	
    	describe "shows error message" do
    		before { click_button submit }
    		it { should have_selector('div.alert-error') }
    	end
    end
    
    context "with valid info" do
    	let(:new_name) { "New Role" }
    	before do
    		fill_in "Name", with: new_name
    	end
    	
    	it "creates a role" do
    		expect { click_button submit }.to change(Role, :count).by(1)
    	end
    	
    	describe "shows success message" do
    		before { click_button submit }
    		it { should have_selector('div.alert-success') }
    	end
    	
    	describe "redirects to the role index" do
    		before { click_button submit }
    		it { should have_selector('title', text: 'Roles') }
    	end
    end
  end
  
  describe "edit" do
  	let(:role) { FactoryGirl.create(:role, piece: piece) }
  	let(:submit) { "Update" }
  	before do
  		visit edit_piece_role_path(piece, role)
  	end
  	
  	context "page" do
	    it { should have_selector('title', text: 'Edit Role') }
	    it { should have_selector('h1', text: piece.name) }
	    it { should have_selector('legend', text: 'Edit Role') }
    end
  	
    context "with invalid URL" do
  		describe "invalid role ID" do
  			#before { visit edit_piece_role_path(piece, 0) }
  			it "redirects to ??" do
    			pending
    			#should have_selector('title', text: 'Roles')
    		end
    	end
    	
    	describe "invalid piece ID" do
  			before { visit edit_piece_role_path(0, role) }
  			it "shows the role edit page" do
  				should have_selector('title', text: 'Edit Role')
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
    		click_button submit
    	end
    	
    	it "shows success message" do
    		should have_selector('div.alert-success')
    	end
    	
    	it "updates the record" do
    		role.reload.name.should == new_name
    	end
    	
    	it "redirects to the role index" do
    		should have_selector('title', text: 'Roles')
    	end
    end
  end
end
