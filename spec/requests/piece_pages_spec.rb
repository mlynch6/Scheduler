require 'spec_helper'

describe "Piece Pages:" do
	subject { page }

	context "#index" do
		it "has correct title" do
			log_in
			click_link "Setup"
	  	click_link "Pieces"
	  	
	  	should have_selector('title', text: 'Pieces')
		  should have_selector('h1', text: 'Pieces')
		end
		
		it "has correct Navigation" do
			log_in
			visit pieces_path
	
			should have_selector('li.active', text: 'Setup')
			should have_selector('li.active', text: 'Pieces')
		end
		
		it "without records" do
			log_in
	  	visit pieces_path
	  	
	    should have_selector('p', text: 'To begin')
			should_not have_selector('td')
			should_not have_selector('div.pagination')
		end
	  
		it "lists records" do
			log_in
			4.times { FactoryGirl.create(:piece_complete, account: current_account) }
			visit pieces_path(per_page: 3)
			
			should have_selector('th', text: "Piece/Choreographer")
			should have_selector('th', text: "Music")
			should have_selector('th', text: "Average Length")
			should have_selector('div.pagination')
			
			Piece.paginate(page: 1, per_page: 3).each do |piece|
				should have_selector('td', text: piece.name)
				should have_selector('td', text: piece.choreographer)
				should have_selector('td', text: piece.music)
				should have_selector('td', text: piece.composer)
				should have_selector('td', text: piece.avg_length)
				
				should have_link('View', href: piece_scenes_path(piece))
				should have_link('Edit', href: edit_pieces_path(piece))
				should have_link('Delete', href: pieces_path(piece))
	    end
		end
		
		it "has links for Super Admin" do
			log_in
			FactoryGirl.create(:piece, account: current_account)
			visit pieces_path
	
			should have_link('Add Piece')
			should have_link('View')
			should have_link('Edit')
			should have_link('Delete')
		end
		
		it "doesn't have links for Employee" do
			log_in_employee
			FactoryGirl.create(:piece, account: current_account)
			visit pieces_path
	
			should_not have_link('Add Piece')
			should have_link('View')
			should_not have_link('Edit')
			should_not have_link('Delete')
		end
		
		it "has links for Administrator" do
			log_in_admin
			FactoryGirl.create(:piece, account: current_account)
			visit pieces_path
	
			should have_link('Add Piece')
			should have_link('View')
			should have_link('Edit')
			should_not have_link('Delete')
		end
	end
	
	context "#new" do
		it "has correct title" do
			log_in
			click_link 'Setup'
	  	click_link 'Pieces'
	  	click_link 'Add Piece'
	
			should have_selector('title', text: 'Add Piece')
			should have_selector('h1', text: 'Add Piece')
		end
		
		it "has correct Navigation" do
			log_in
			visit new_piece_path
	
			should have_selector('li.active', text: 'Setup')
			should have_selector('li.active', text: 'Pieces')
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				visit new_piece_path
		  	click_button 'Create'
		
				should have_selector('div.alert-danger')
			end
			
			it "doesn't create Piece" do
				log_in
				visit new_piece_path
		
				expect { click_button 'Create' }.not_to change(Piece, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Piece" do
				log_in
				visit new_piece_path
				
		  	new_name = Faker::Lorem.word
		  	new_choreographer = Faker::Name.name
		  	new_music = Faker::Lorem.word
		  	new_composer = Faker::Name.name
		  	
				fill_in "Name", with: new_name
				fill_in "Choreographer", with: new_choreographer
				fill_in "Music", with: new_music
				fill_in "Composer", with: new_composer
				fill_in "Average Length", with: 82
				click_button 'Create'

				should have_selector('div.alert-success')
				should have_selector('title', text: 'Pieces')
				should have_content(new_name)
				should have_content(new_choreographer)
				should have_content(new_music)
				should have_content(new_composer)
				should have_content('82 min')
			end
		end
	end

	context "#edit" do
		it "has correct title" do
			log_in
			piece = FactoryGirl.create(:piece, account: current_account)
			click_link 'Setup'
	  	click_link "Pieces"
	  	click_link "Edit"
	  	
	  	should have_selector('title', text: 'Edit Piece')
			should have_selector('h1', text: 'Edit Piece')
		end
		
		it "has correct Navigation" do
			log_in
	  	piece = FactoryGirl.create(:piece, account: current_account)
	  	visit edit_piece_path(piece)
	
			should have_selector('li.active', text: 'Setup')
			should have_selector('li.active', text: 'Pieces')
		end
		
	  it "with error shows error message" do
	  	log_in
	  	piece = FactoryGirl.create(:piece, account: current_account)
	  	visit edit_piece_path(piece)
	  	fill_in "Name", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-danger')
		end
	
		it "with bad record in URL shows 'Record Not Found' error" do
			pending
			log_in
			visit edit_piece_path(0)
	
			should have_selector('title', text: 'Pieces')
			should have_selector('div.alert-danger', text: 'Record Not Found')
		end
		
		it "record with wrong account shows 'Record Not Found' error" do
			pending
			log_in
			piece_wrong_account = FactoryGirl.create(:piece)
			visit edit_piece_path(piece_wrong_account)
	
			should have_selector('title', text: 'Pieces')
			should have_selector('div.alert-danger', text: 'Record Not Found')
		end
	 
		it "with valid info" do
			log_in
			piece = FactoryGirl.create(:piece, account: current_account)
			new_name = Faker::Lorem.word
			visit pieces_path
			click_link "edit_#{piece.id}"
			
			new_name = Faker::Lorem.word
		  new_choreographer = Faker::Name.name
		  new_music = Faker::Lorem.word
		  new_composer = Faker::Name.name
		  
		  fill_in "Name", with: new_name
			fill_in "Choreographer", with: new_choreographer
			fill_in "Music", with: new_music
			fill_in "Composer", with: new_composer
			fill_in "Average Length", with: 82
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Pieces')
			should have_content(new_name)
			should have_content(new_choreographer)
			should have_content(new_music)
			should have_content(new_composer)
			should have_content('82 min')
		end
	end

	context "#destroy" do
		it "deletes the record" do
	  	log_in
			piece = FactoryGirl.create(:piece, account: current_account)
			visit pieces_path
			click_link "delete_#{piece.id}"
			
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Pieces')
			
			click_link 'Pieces'
			should_not have_content(piece.name)
		end
	end
	
	context "#show" do		
		it "has correct title" do
			log_in
			piece = FactoryGirl.create(:piece_complete, account: current_account)
			click_link "Setup"
			click_link "Pieces"
			click_link "View"
			
	  	should have_selector('title', text: piece.name)
	  	should have_selector('title', text: 'Overview')
			should have_selector('h1', text: piece.name)
		end
		
		it "has correct Navigation" do
			log_in
			piece = FactoryGirl.create(:piece_complete, account: current_account)
			visit piece_path(piece)
			
			should have_selector('li.active', text: 'Setup')
			should have_selector('li.active', text: 'Pieces')
		end
		
		it "has links" do
			log_in
			piece = FactoryGirl.create(:piece_complete, account: current_account)
			visit piece_path(piece)
			
	  	should have_link('Edit')
	  	should have_link('Overview')
	  	should have_link('Scenes')
	  	should have_link('Characters')
		end
		
		it "displays correct data" do
			log_in
			piece = FactoryGirl.create(:piece_complete, account: current_account)
			visit piece_path(piece)
			
			should have_content(piece.name)
			should have_content(piece.choreographer)
			should have_content(piece.music)
			should have_content(piece.composer)
			should have_content("#{piece.avg_length} min")
		end
	end
end
