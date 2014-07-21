require 'spec_helper'

describe "Character Pages:" do
  subject { page }

	context "#index" do
		before do
  		log_in
  		@piece = FactoryGirl.create(:piece, account: current_account)
	  	
			click_link 'Setup'
	  	click_link "Pieces"
	  	click_link @piece.name
	  	click_link "Characters"
		end
		
  	it "has correct title" do
	  	should have_title "#{@piece.name} | Characters"
		  should have_selector 'h1', text: "#{@piece.name}"
			should have_selector 'h1 small', text: "Characters"
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Pieces'
			should have_selector 'li.active', text: 'Characters'
		end
		
		it "without records" do
	    should have_selector 'p', text: 'To begin'
			should_not have_selector 'td'
		end
	  
		it "lists records" do
			4.times { FactoryGirl.create(:character, account: current_account, piece: @piece) }
			visit piece_characters_path(@piece)
	
			should have_selector 'th', text: "Characters"
	
			@piece.characters.each do |character|
				should have_selector 'td', text: character.name
				should have_link character.name, href: edit_character_path(character)
				should have_link 'Delete', href: character_path(character)
	    end
		end
		
		it "shows Male gender on list" do
			FactoryGirl.create(:character, :male, account: current_account, piece: @piece)
			visit piece_characters_path(@piece)
	
			should have_selector 'td', text: 'M'
		end
		
		it "shows Female gender on list" do
			FactoryGirl.create(:character, :female, account: current_account, piece: @piece)
			visit piece_characters_path(@piece)
	
			should have_selector 'td', text: 'F'
		end
		
		it "shows Animal on list" do
			FactoryGirl.create(:character, :animal, account: current_account, piece: @piece)
			visit piece_characters_path(@piece)
	
			should have_selector 'td', text: 'A'
		end
		
		it "shows Child on list" do
			FactoryGirl.create(:character, :child, account: current_account, piece: @piece)
			visit piece_characters_path(@piece)
	
			should have_selector 'td', text: 'K'
		end
		
		it "shows Speaking Role on list" do
			FactoryGirl.create(:character, :speaking, account: current_account, piece: @piece)
			visit piece_characters_path(@piece)
	
			should have_selector 'span.glyphicon-bullhorn'
		end
		
		it "has links for Super Admin" do
			character = FactoryGirl.create(:character, account: current_account, piece: @piece)
			visit piece_characters_path(@piece)
	
			should have_link character.name
			should have_link 'Delete'
			
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
	
	context "#new" do
		before do
			log_in
  		@piece = FactoryGirl.create(:piece, account: current_account)

	  	click_link 'Setup'
	  	click_link "Pieces"
	  	click_link @piece.name
	  	click_link "Characters"
	  	click_link "Add Character"
		end
		
		it "has correct title" do
			should have_title "#{@piece.name} | Add Character"
		  should have_selector 'h1', text: "#{@piece.name}"
			should have_selector 'h1 small', text: "Add Character"
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Pieces'
			should have_selector 'li.active', text: 'Characters'
		end
		
		it "has correct fields on form" do
	  	should have_field 'Character'
			should have_select 'Gender'
			should have_field 'character_is_child'
			should have_field 'character_animal'
			should have_field 'character_speaking'
			should have_link 'Cancel', href: piece_characters_path(@piece)
		end
		
		context "with error" do
			it "shows error message" do
		  	click_button 'Create'
		
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Piece" do
				expect { click_button 'Create' }.not_to change(Character, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Character" do
		  	new_name = Faker::Lorem.word
				fill_in "Character", with: new_name
				click_button 'Create'

				should have_selector 'div.alert-success'
				should have_title "Characters"
				should have_content new_name
			end
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
	
	context "#edit" do
		before do
			log_in
			@piece = FactoryGirl.create(:piece, account: current_account)
			@character = FactoryGirl.create(:character, account: current_account, piece: @piece)
			
	  	click_link 'Setup'
	  	click_link "Pieces"
	  	click_link @piece.name
	  	click_link "Characters"
	  	click_link @character.name
		end
		
		it "has correct title" do
	  	should have_title "#{@piece.name} | Edit Character"
		  should have_selector 'h1', text: "#{@piece.name}"
			should have_selector 'h1 small', text: "Edit Character"
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Pieces'
			should have_selector 'li.active', text: 'Characters'
		end
		
		it "has correct fields on form" do
	  	should have_field 'Character'
			should have_select 'Gender'
			should have_field 'character_is_child'
			should have_field 'character_animal'
			should have_field 'character_speaking'
			should have_link 'Cancel', href: piece_characters_path(@piece)
		end
		
	  it "with error shows error message" do
	  	fill_in "Character", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "with valid info" do
			new_name = Faker::Lorem.word
			fill_in "Character", with: new_name
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title "#{@piece.name} | Characters"
			should have_content new_name
		end
		
		it "has links for Super Admin" do
	  	should have_link 'Overview'
	  	should have_link 'Scenes'
	  	should have_link 'Characters'
			
			should have_link 'Add Piece'
			should have_link 'Delete Piece'
			should have_link 'Add Character'
			should have_link 'Delete Character'
			should have_link 'Add Scene'
			should have_link 'Download Scenes PDF'
		end
	end
  
  describe "#destroy" do
		before do
	  	log_in
			@piece = FactoryGirl.create(:piece, account: current_account)
			@character = FactoryGirl.create(:character, account: current_account, piece: @piece)
		
			@season = FactoryGirl.create(:season, account: current_account)
			@sp = FactoryGirl.create(:season_piece, account: current_account, season: @season, piece: @piece)
			@cast = FactoryGirl.create(:cast, account: current_account, season_piece: @sp)
			@casting = FactoryGirl.create(:casting, account: current_account, cast: @cast, character: @character)
		end
		
		context "without a published cast" do
			before do			
				visit piece_characters_path(@piece)
				click_link "delete_#{@character.id}"
			end
		
	 	 	it "removes the character from the piece" do
				should have_selector 'div.alert-success'
				should have_title "#{@piece.name} | Characters"
			
				should_not have_content @character.name
			end
				
			it "removes the character from the unpublished cast" do
				visit season_piece_casts_path(@sp)
				
				should have_title "#{@season.name} | #{@piece.name} | Casting"
				should_not have_content @character.name
			end
		end
		
		context "with a published cast" do
			before do
				@sp_pub = FactoryGirl.create(:season_piece, :published, account: current_account, piece: @piece)
				@cast_pub = FactoryGirl.create(:cast, account: current_account, season_piece: @sp_pub)
				@casting_pub = FactoryGirl.create(:casting, account: current_account, cast: @cast_pub, character: @character)
			
				visit piece_characters_path(@piece)
				click_link "delete_#{@character.id}"
			end
		
	 	 	it "removes the character from the piece" do
				should have_selector 'div.alert-success'
				should have_title "#{@piece.name} | Characters"
			
				should_not have_content @character.name
			end
				
			it "removes the character from the unpublished cast" do
				visit season_piece_casts_path(@sp)
				
				should have_title "#{@season.name} | #{@piece.name} | Casting"
				should_not have_selector 'span.glyphicon-lock'
				should_not have_content @character.name
			end
			
			it "does NOT remove the character from the published cast" do
				visit season_piece_casts_path(@sp_pub)
			
				should have_title "#{@sp_pub.season.name} | #{@piece.name} | Casting"
				should have_content @character.name
			end
		end
  end

	describe "#sort" do
		before do
  		log_in
  		@piece = FactoryGirl.create(:piece, account: current_account)
			@character = FactoryGirl.create(:character, account: current_account, piece: @piece)
	  	
			click_link 'Setup'
	  	click_link "Pieces"
	  	click_link @piece.name
	  	click_link "Characters"
		end
		
  	it "has sort drag handle" do
			should have_selector '.handle'
		end
  end
end
