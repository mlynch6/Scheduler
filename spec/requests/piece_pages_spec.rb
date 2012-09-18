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
	    
	    it "has a 'Show' link" do
	    	should have_link(Piece.first.name, href: piece_scenes_path(Piece.first))
	    end
	    
	    it "has an 'Edit' link" do
	    	should have_link('Edit', href: edit_piece_path(Piece.first))
	    end
	    
	    it "has a 'Delete' link" do
	    	should have_link('Delete', href: piece_path(Piece.first))
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
	    
    describe "redirects to show piece page" do
    	before { click_link 'Delete' }
    	#specify { response.should redirect_to(pieces_path) }
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
	    
	    it "has Cancel button back to index" do
	    	should have_link('Cancel', href: pieces_path)
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
    		fill_in "piece_scenes_attributes_1_order_num", with: "1"
    	end
    	
    	it "creates a piece"do
    		expect { click_button submit }.to change(Piece, :count).by(1)
    	end
    	
    	it "creates associated scenes"do
    		expect { click_button submit }.to change(Scene, :count).by(2)
    	end
    	
    	describe "shows success message" do
    		before { click_button submit }
    		it { should have_selector('div.alert-success') }
    	end
    	
    	describe "redirects to the piece scenes page" do
    		before { click_button submit }
    		it { should have_selector('title', text: new_name) }
    		it { should have_selector('title', text: 'Scenes') }
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
    
    context "with invalid record" do
  		before { visit edit_piece_path(0) }
  		
  		it "redirects to the list (index)" do
    		should have_selector('title', text: 'All Pieces')
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
    	
    	describe "redirects to the piece scenes page" do
    		it { should have_selector('title', text: new_name) }
    		it { should have_selector('title', text: 'Scenes') }
    	end
    end
  end
end
