require 'spec_helper'

describe "Piece Pages:" do
	subject { page }

	context "#index" do
		before do
			log_in
			click_link "Setup"
	  	click_link "Pieces"
		end
	
		it "has correct title" do	  	
	  	should have_title 'Pieces'
		  should have_selector 'h1', text: 'Pieces'
		end
	
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Pieces'
		end
	
		it "without records" do
	    should have_selector 'p', text: 'To begin'
			should_not have_selector'td'
			should_not have_selector 'div.pagination'
		end
  
		it "lists records" do
			4.times { FactoryGirl.create(:piece_complete, account: current_account) }
			visit pieces_path(per_page: 3)
		
			should have_selector 'th', text: "Piece/Choreographer"
			should have_selector 'th', text: "Music"
			should have_selector 'th', text: "Average Length"
			should have_selector 'div.pagination'
		
			Piece.paginate(page: 1, per_page: 3).each do |piece|
				should have_selector 'td', text: piece.name
				should have_selector 'td', text: piece.choreographer
				should have_selector 'td', text: piece.music
				should have_selector 'td', text: piece.composer
				should have_selector 'td', text: piece.avg_length
			
				should have_link piece.name, href: piece_scenes_path(piece)
				should have_link 'Delete', href: pieces_path(piece)
	    end
		end
	
		it "has links for Super Admin" do
			piece = FactoryGirl.create(:piece, account: current_account)
			visit pieces_path
		
			should have_link 'Add Piece'
			should have_link piece.name
			should have_link 'Delete'
		end
	end
	
	context "#new" do
		before do
			log_in
			click_link 'Setup'
	  	click_link 'Pieces'
	  	click_link 'Add Piece'
		end
		
		it "has correct title" do
			should have_title 'Add Piece'
			should have_selector 'h1', text: 'Pieces'
			should have_selector 'h1 small', text: 'Add'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Pieces'
		end
		
		it "has correct fields on form" do
			should have_field 'Name'
	    should have_field 'Choreographer'
	    should have_field 'Music'
	    should have_field 'Composer'
	    should have_field 'Average Length'
			should have_link 'Cancel', href: pieces_path
		end
		
		context "with error" do
			it "shows error message" do
		  	click_button 'Create'
		
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Piece" do
				expect { click_button 'Create' }.not_to change(Piece, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Piece" do
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

				should have_selector 'div.alert-success'
				should have_title 'Pieces'
				should have_content new_name
				should have_content new_choreographer
				should have_content new_music
				should have_content new_composer
				should have_content '82 min'
			end
		end
		
		it "has links for Super Admin" do
			should have_link 'Add Piece'
		end
	end

	context "#edit" do
		before do
			log_in
			@piece = FactoryGirl.create(:piece, account: current_account)
			click_link 'Setup'
	  	click_link 'Pieces'
	  	click_link @piece.name
			click_link @piece.name
		end
	
		it "has correct title" do
	  	should have_title 'Edit Piece'
			should have_selector 'h1', text: 'Pieces'
			should have_selector 'h1 small', text: 'Edit'
		end
	
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Pieces'
		end
	
		it "has correct fields on form" do
			should have_field 'Name'
	    should have_field 'Choreographer'
	    should have_field 'Music'
	    should have_field 'Composer'
	    should have_field 'Average Length'
			should have_link 'Cancel', href: piece_path(@piece)
		end
	
	  it "with error shows error message" do
	  	fill_in "Name", with: ""
	  	click_button 'Update'

			should have_selector 'div.alert-danger'
		end
 
		it "with valid info" do
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

			should have_selector 'div.alert-success'
			should have_title 'Pieces'
			should have_content new_name
			should have_content new_choreographer
			should have_content new_music
			should have_content new_composer
			should have_content '82 min'
		end
		
		it "has links for Super Admin" do
	  	should have_link 'Overview'
	  	should have_link 'Scenes'
	  	should have_link 'Characters'
			
			should have_link 'Add Piece'
			should have_link 'Delete Piece'
			should have_link 'Add Character'
			should have_link 'Add Scene'
			should have_link 'Download Scenes PDF'
		end
	end

	context "#destroy" do
		before do
	  	log_in
			@piece = FactoryGirl.create(:piece, account: current_account)
			visit pieces_path
			click_link "delete_#{@piece.id}"
		end
	
		it "deletes the record" do		
			should have_selector 'div.alert-success'
			should have_title 'Pieces' 
		
			click_link 'Pieces'
			should_not have_content @piece.name
		end
	end
	
	context "#show" do
		before do
			log_in
			@piece = FactoryGirl.create(:piece_complete, account: current_account)
			click_link "Setup"
			click_link "Pieces"
			click_link "#{@piece.name}"
		end	
		
		it "has correct title" do	
	  	should have_title "#{@piece.name} | Overview"
			should have_selector 'h1', text: @piece.name
			should have_selector 'h1 small', text: 'Overview'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Pieces'
		end
		
		it "displays correct data" do
			should have_content @piece.name
			should have_content @piece.choreographer
			should have_content @piece.music
			should have_content @piece.composer
			should have_content "#{@piece.avg_length} min"
		end
		
		it "has links for Super Admin" do
	  	should have_link @piece.name
	  	should have_link 'Overview'
	  	should have_link 'Scenes'
	  	should have_link 'Characters'
			
			should have_link 'Add Piece'
			should have_link 'Delete Piece'
			should have_link 'Add Character'
			should have_link 'Add Scene'
			should have_link 'Download Scenes PDF'
		end
	end
end
