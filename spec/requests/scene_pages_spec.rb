require 'spec_helper'

describe "Scene Pages:" do
  subject { page }
  let(:piece) { FactoryGirl.create(:piece) }
  
  describe "index" do
  	before do
  		visit piece_scenes_path(piece)
  	end
  	
		context "page" do
			it { should have_selector('title', text: piece.name) }
	    it { should have_selector('title', text: 'Scenes') }
	    it { should have_selector('h1', text: piece.name) }
	    
	    it "has a 'New' link" do
	    	should have_link('New', href: new_piece_scene_path(piece))
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
			before(:all) { piece.scenes.delete_all }
    	
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
    		31.times { FactoryGirl.create(:scene, piece: piece) }
    	end
    	after(:all)  { piece.scenes.delete_all }
    	
    	it "lists each scene" do
    		piece.scenes.paginate(page: 1).each do |scene|
    			should have_selector('td', text: scene.name)
    			should have_selector('td', text: scene.order_num.to_s)
    		end
    	end
    	
    	it "has pagination" do
	    	should have_selector('div.pagination')
	    end
	    
	    it "has a 'Show' link" do
	    	should have_link(piece.scenes.first.name, href: piece_scene_path(piece, piece.scenes.first))
	    end
	    
	    it "has an 'Edit' link" do
	    	should have_link('Edit', href: edit_piece_scene_path(piece, piece.scenes.first))
	    end
	    
	    it "has a 'Delete' link" do
	    	should have_link('Delete', href: piece_scene_path(piece, piece.scenes.first))
	    end
    end
  end
  
  describe "destroy" do
  	before do
  		FactoryGirl.create(:scene, piece: piece)
  		visit piece_scenes_path(piece)
  	end
  			
    it "deletes a scene" do
    	expect { click_link 'Delete' }.to change(Scene, :count).by(-1)
    end
		  	
  	describe "shows success message" do
  		before { click_link 'Delete' }
			it { should have_selector('div.alert-success') }
    end
	    
    describe "redirects to scene index page" do
    	before { click_link 'Delete' }
			it { should have_selector('title', text: 'Scenes') }
		end
  end
  
  describe "new" do
  	let(:submit) { "Create" }
  	before do
  		visit new_piece_scene_path(piece)
  	end
  	
  	context "page" do
	    it { should have_selector('title', text: 'New Scene') }
	    it { should have_selector('h1', text: piece.name) }
	    it { should have_selector('legend', text: 'New Scene') }
	  end
    
    context "with invalid info" do   	
    	it "does NOT create a scene" do
    		expect { click_button submit }.not_to change(Scene, :count)
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
    		fill_in "Order", with: 1
    	end
    	
    	it "creates a scene" do
    		expect { click_button submit }.to change(Scene, :count).by(1)
    	end
    	
    	describe "shows success message" do
    		before { click_button submit }
    		it { should have_selector('div.alert-success') }
    	end
    	
    	describe "redirects to the scene index for the piece" do
    		before { click_button submit }
    		it { should have_selector('title', text: 'Scenes') }
    	end
    end
  end
  
  describe "edit" do
  	let(:scene) { FactoryGirl.create(:scene, piece: piece) }
  	let(:submit) { "Update" }
  	before do
  		visit edit_piece_scene_path(piece, scene)
  	end
  	
  	context "page" do
	    it { should have_selector('title', text: 'Edit Scene') }
	    it { should have_selector('h1', text: piece.name) }
	    it { should have_selector('legend', text: 'Edit Scene') }
    end
    
    context "with invalid URL" do
  		describe "invalid scene ID" do
  			#before { visit edit_piece_scene_path(piece, 0) }
  			it "redirects to ??" do
    			pending
    			#should have_selector('title', text: 'Scenes')
    		end
    	end
    	
    	describe "invalid piece ID" do
  			before { visit edit_piece_scene_path(0, scene) }
  			it "shows the scene edit page" do
  				should have_selector('title', text: 'Edit Scene')
    		end
    	end
  	end
    
    context "with invalid info" do
			before do
    		fill_in "Name", with: ""
    		fill_in "Order", with: ""
    		click_button submit 
    	end
    		
    	it "shows error message" do
    		should have_selector('div.alert-error')
    	end
    end
    
    context "with valid info" do
    	let(:new_name) { "Updated Name" }
    	let(:new_order) { 15 }
    	before do
    		fill_in "Name", with: new_name
    		fill_in "Order", with: new_order
    		click_button submit
    	end
    	
    	it "shows success message" do
    		should have_selector('div.alert-success')
    	end
    	
    	it "updates the record" do
    		scene.reload.name.should == new_name
    		scene.reload.order_num.should == new_order
    	end
    	
    	it "redirects to the scene index" do
    		should have_selector('title', text: 'Scenes')
    	end
    end
  end
  
  describe "show" do
  	pending
  end
end