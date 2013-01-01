require 'spec_helper'

describe "Piece Pages:" do
	subject { page }

	context "#index" do
		it "without records" do
			log_in
			current_account.pieces.delete_all
	  	visit pieces_path
	  	
	  	should have_selector('title', text: 'All Pieces')
		  should have_selector('h1', text: 'All Pieces')
	  	
	    should have_selector('div.alert', text: "No records found")
			should_not have_selector('td')
			should_not have_selector('div.pagination')
		end
	  
		it "lists records" do
			log_in
			4.times { FactoryGirl.create(:piece, account: current_account) }
			visit pieces_path(per_page: 3)
	
			should have_selector('div.pagination')
			Piece.active.paginate(page: 1, per_page: 3).each do |pieces_path|
				should have_selector('td', text: pieces_path.name)
				should have_link('Edit', href: edit_pieces_path_path(pieces_path))
				should have_link('Delete', href: pieces_path_path(pieces_path))
	    end
		end
		
		it "doesn't have links for Employee" do
			log_in_employee
			FactoryGirl.create(:piece, account: current_account)
			visit pieces_path
	
			should_not have_link('New')
			should_not have_link('Edit')
			should_not have_link('Delete')
		end
		
		it "has links for Administrator" do
			log_in_admin
			FactoryGirl.create(:piece, account: current_account)
			visit pieces_path
	
			should have_link('New')
			should have_link('Edit')
			should_not have_link('Delete')
		end
		
		it "has active filter" do
			log_in
	  	FactoryGirl.create(:piece, account: current_account)
			FactoryGirl.create(:piece_inactive, account: current_account)
	  	visit pieces_path
	  	click_link 'Active'
	  	
			should have_selector('td', text: 'Active')
			should_not have_selector('td', text: 'Inactive')
		end
	 
		it "has inactive filter" do
			log_in
	  	FactoryGirl.create(:piece, account: current_account)
			FactoryGirl.create(:piece_inactive, account: current_account)
	  	visit pieces_path
	  	click_link 'Inactive'
	  	
			should have_selector('td', text: 'Inactive')
			should_not have_selector('td', text: 'Active')
		end
	end
	
	context "#new" do
		it "record with error" do
			log_in
			visit pieces_path
	  	click_link 'New'
	
			should have_selector('title', text: 'New Piece')
			should have_selector('h1', text: 'New Piece')
	
			expect { click_button 'Create' }.not_to change(Piece, :count)
			should have_selector('div.alert-error')
			
#			context "Scenes section" do
#		  	it "has a Scenes section" do
#		    	should have_content('Scenes')
#		    end
#		    
#		    it "has 'Add Scene' button" do
#		    	should have_link('Add Scene')
#		    end
#		    
#		    it "clicking 'Add Scene' button adds new row of form inputs" do
#		    	pending
#		    end
#		  end
#		  
#		  context "Roles section" do
#		  	it "has a Roles section" do
#		    	should have_content('Roles')
#		    end
#		    
#		    it "has 'Add Role' button" do
#		    	should have_link('Add Role')
#		    end
#		    
#		    it "clicking 'Add Role' button adds new row of form inputs" do
#		    	pending
#		    end
#		  end
		end
	
		it "record with valid info" do
			log_in
			visit pieces_path
	  	click_link 'New'
	  	new_name = Faker::Lorem.word
			fill_in "Name", with: new_name
			click_button 'Create'
	
			#expect { click_button 'Create' }.to change(Piece, :count).by(1)
#    	it "creates associated scenes" do
#    		expect { click_button submit }.to change(Scene, :count).by(2)
#    	end
#    	
#    	it "creates associated roles" do
#    		expect { click_button submit }.to change(Role, :count).by(2)
#    	end
			should have_selector('div.alert-success')
			should have_selector('title', text: 'All Pieces')
			should have_content(new_name)
		end
	end

	context "#edit" do
	  it "record with error" do
	  	log_in
	  	piece = FactoryGirl.create(:piece, account: current_account)
	  	visit edit_piece_path(piece)
	  	fill_in "Name", with: ""
	  	click_button 'Update'
	
			should have_selector('title', text: 'Edit Piece')
			should have_selector('h1', text: 'Edit Piece')
			should have_selector('div.alert-error')
		end
	
		it "with bad record in URL" do
			pending
			log_in
			edit_piece_path(0)
	
			should have_content('Record Not Found')
			should have_selector('div.alert-error', text: 'Record Not Found')
			should have_selector('title', text: 'All Pieces')
		end
	 
		it "with valid info" do
			log_in
			piece = FactoryGirl.create(:piece, account: current_account)
			new_name = Faker::Lorem.word
			visit pieces_path
			click_link "edit_#{piece.id}"
			fill_in "Name", with: new_name
			select "Inactive", from: "Status"
			click_button 'Update'
	
			should have_selector('div.alert-success')
			piece.reload.name.should == new_name
			piece.reload.active.should be_false
			should have_selector('title', text: 'All Pieces')
		end
	end

	it "destroy record", :js => true, :driver => :webkit do
		pending "need to test with js Delete confirmation"
  	log_in
		piece = FactoryGirl.create(:piece, account: current_account)
		visit pieces_path
		click_link "delete_#{piece.id}"
		
		#expect { click_link "delete_#{piece.id}" }.to change(Piece, :count).by(-1)
		should have_selector('div.alert-success')
		should have_selector('title', text: 'All Pieces')
		should_not have_content(piece.name)
	end

#  
#	describe "show" do
#		let(:piece) { FactoryGirl.create(:piece) }
#  	before do
#  		visit piece_path(piece)
#  	end
#  	
#  	context "page" do
#	    it { should have_selector('title', text: piece.name) }
#	    it { should have_selector('title', text: 'Performances') }
#	    it { should have_selector('h1', text: piece.name) }
#	    
#	    describe "has sub navigation" do
#		    it "has a 'Performances' link" do
#	    		should have_link('Performances', href: piece_path(piece))
#	    	end
#	    	
#	    	it "has a 'Scenes' link" do
#	    		should have_link('Scenes', href: piece_scenes_path(piece))
#	    	end
#	    	
#	    	it "has a 'Roles' link" do
#	    		should have_link('Roles', href: piece_roles_path(piece))
#	    	end
#	    end
#    end
#	end
end
