require 'spec_helper'

describe "Character Pages:" do
  subject { page }

	context "#index" do
  	it "has correct title & table headers" do
  		log_in
  		piece = FactoryGirl.create(:piece, account: current_account)
  		FactoryGirl.create(:character, account: current_account, piece: piece)
	  	click_link "Active Pieces"
	  	click_link "View"
	  	click_link "Characters"
	  	
	  	should have_selector('title', text: "#{piece.name} | Characters")
		  should have_selector('h1', text: "#{piece.name}")
		  
		  should have_selector('th', text: "Characters")
		end
		
		it "without records" do
			log_in
			piece = FactoryGirl.create(:piece, account: current_account)
	  	visit piece_characters_path(piece)
	  	
	    should have_selector('div.alert')
			should_not have_selector('td')
		end
	  
		it "lists records" do
			log_in
			piece = FactoryGirl.create(:piece, account: current_account)
			4.times { FactoryGirl.create(:character, account: current_account, piece: piece) }
			visit piece_characters_path(piece)
	
			piece.characters.each do |character|
				should have_selector('td', text: character.name)
				should have_link('Edit', href: edit_character_path(character))
				should have_link('Delete', href: character_path(character))
	    end
		end
		
		it "doesn't have links for Employee" do
			log_in_employee
			piece = FactoryGirl.create(:piece, account: current_account)
			FactoryGirl.create(:character, account: current_account, piece: piece)
			visit piece_characters_path(piece)
	
			should_not have_link('Add Character')
			should_not have_link('Edit')
			should_not have_link('Delete')
		end
		
		it "has links for Administrator" do
			log_in_admin
			piece = FactoryGirl.create(:piece, account: current_account)
			FactoryGirl.create(:character, account: current_account, piece: piece)
			visit piece_characters_path(piece)
	
			should have_link('Add Character')
			should have_link('Edit')
			should have_link('Delete')
		end
	end
	
	context "#new" do
		it "has correct title" do
			log_in
  		piece = FactoryGirl.create(:piece, account: current_account)
	  	click_link "Active Pieces"
	  	click_link "View"
	  	click_link "Characters"
	  	click_link "Add Character"
	
			should have_selector('title', text: "#{piece.name} | Add Character")
		  should have_selector('h1', text: "Add Character for #{piece.name}")
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				piece = FactoryGirl.create(:piece, account: current_account)
				visit new_piece_character_path(piece)
		  	click_button 'Create'
		
				should have_selector('div.alert-error')
			end
			
			it "doesn't create Piece" do
				log_in
				piece = FactoryGirl.create(:piece, account: current_account)
				visit new_piece_character_path(piece)
		
				expect { click_button 'Create' }.not_to change(Character, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Character" do
				log_in
				piece = FactoryGirl.create(:piece, account: current_account)
				visit new_piece_character_path(piece)
				
		  	new_name = Faker::Lorem.word
				fill_in "Character", with: new_name
				click_button 'Create'

				should have_selector('div.alert-success')
				should have_selector('title', text: 'Characters')
				should have_content(new_name)
			end
		end
	end
	
	context "#edit" do
		it "has correct title" do
			log_in
			piece = FactoryGirl.create(:piece, account: current_account)
			character = FactoryGirl.create(:character, account: current_account, piece: piece)
	  	click_link "Active Pieces"
	  	click_link "View"
	  	click_link "Characters"
	  	click_link "Edit"
	  	
	  	should have_selector('title', text: "#{piece.name} | Edit Character")
		  should have_selector('h1', text: "Edit Character for #{piece.name}")
		end
		
	  it "with error shows error message" do
	  	log_in
	  	piece = FactoryGirl.create(:piece, account: current_account)
			character = FactoryGirl.create(:character, account: current_account, piece: piece)
	  	visit edit_character_path(character)
	  	fill_in "Character", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-error')
		end
	
		it "with bad record in URL shows 'Record Not Found' error" do
			pending
			log_in
			visit edit_character_path(0)
	
			should have_content('Record Not Found')
		end
		
		it "record with wrong account shows 'Record Not Found' error" do
			pending
			log_in
			character_wrong_account = FactoryGirl.create(:character)
			visit edit_character_path(character_wrong_account)
	
			should have_content('Record Not Found')
		end
	 
		it "with valid info" do
			log_in
			piece = FactoryGirl.create(:piece, account: current_account)
			character = FactoryGirl.create(:character, account: current_account, piece: piece)
	  	visit edit_character_path(character)
			
			new_name = Faker::Lorem.word
			fill_in "Character", with: new_name
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: "#{piece.name} | Characters")
			should have_content(new_name)
		end
	end
  
  describe "#destroy" do
  	it "deletes the record" do
	  	log_in
			piece = FactoryGirl.create(:piece, account: current_account)
			character = FactoryGirl.create(:character, account: current_account, piece: piece)
			visit piece_characters_path(piece)
			click_link "delete_#{character.id}"
			
			should have_selector('div.alert-success')
			should have_selector('title', text: "#{piece.name} | Characters")
			
			should_not have_content(character.name)
		end
  end

	describe "#sort" do
  	pending "IMPLEMENTED, BUT NO TESTS"
  end
end
