require 'spec_helper'

describe "Scene Pages:" do
  subject { page }

	context "#index" do
		before do
  		log_in
  		@piece = FactoryGirl.create(:piece, account: current_account)
  		
	  	click_link 'Setup'
	  	click_link "Pieces"
	  	click_link @piece.name
	  	click_link "Scenes"
		end
		
  	it "has correct title" do
	  	should have_title "#{@piece.name} | Scenes"
		  should have_selector 'h1', text: "#{@piece.name}"
			should have_selector 'h1 small', text: 'Scenes'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Pieces'
			should have_selector 'li.active', text: 'Scenes'
		end
		
		it "without records" do
	    should have_selector 'p', text: 'To begin'
			should_not have_selector 'td'
		end
	  
		it "lists records" do
			4.times {
				scene = FactoryGirl.create(:scene, account: current_account, piece: @piece)
				3.times {
					character = FactoryGirl.create(:character, account: current_account, piece: @piece)
					FactoryGirl.create(:appearance, scene: scene, character: character)
				}
			}
			visit piece_scenes_path(@piece)
	
			should have_selector 'th', text: "Scene"
		  should have_selector 'th', text: "Characters"
		  should have_selector 'th', text: "Track"
		  
			@piece.scenes.each do |scene|
				should have_selector 'td', text: scene.name
				scene.characters.each do |character|
					should have_content character.name
				end
				should have_selector 'td', text: scene.track
				should have_link scene.name, href: edit_scene_path(scene)
				should have_link 'Delete', href: scene_path(scene)
	    end
		end
		
		it "has links for Super Admin" do
			scene = FactoryGirl.create(:scene, account: current_account, piece: @piece)
			visit piece_scenes_path(@piece)
	
			should have_link scene.name
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
		
		it "allows download to PDF" do
			log_in
			piece = FactoryGirl.create(:piece, account: current_account)
			4.times {
				scene = FactoryGirl.create(:scene, account: current_account, piece: piece)
				3.times {
					character = FactoryGirl.create(:character, account: current_account, piece: piece)
					FactoryGirl.create(:appearance, scene: scene, character: character)
				}
			}
			visit piece_scenes_path(piece)
			click_link "Download Scenes PDF"

# HOW TO TEST CONTENTS ??
#			piece.scenes.each do |scene|
#				should have_selector('td', text: scene.name)
#				scene.characters.each do |character|
#					should have_content(character.name)
#				end
#				should have_selector('td', text: scene.track)
#	    end
		end
	end
	
	context "#new" do
		before do
			log_in
  		@piece = FactoryGirl.create(:piece, account: current_account)
			@character = FactoryGirl.create(:character, account: current_account, piece: @piece)
  		click_link 'Setup'
	  	click_link "Pieces"
	  	click_link @piece.name
	  	click_link "Scenes"
	  	click_link "Add Scene"
		end
		
		it "has correct title" do
			should have_title "#{@piece.name} | Add Scene"
		  should have_selector 'h1', text: @piece.name
			should have_selector 'h1 small', text: 'Add Scene'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Pieces'
			should have_selector 'li.active', text: 'Scenes'
		end
		
		it "has correct fields on form" do
	    should have_field 'Scene'
	    should have_field 'Track'
	    should have_content 'Characters'	#Using Chosen
			should have_link 'Cancel', href: piece_scenes_path(@piece)
		end
		
		context "with error" do
			it "shows error message" do
		  	click_button 'Create'
		
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Piece" do
				expect { click_button 'Create' }.not_to change(Scene, :count)
			end
		end
	
		context "with valid info" do			
			it "creates new Scene without Characters" do
		  	new_name = Faker::Lorem.word
		  	new_track = Faker::Lorem.word
				fill_in "Scene", with: new_name
				fill_in "Track", with: new_track
				click_button 'Create'

				should have_selector 'div.alert-success'
				should have_title "Scenes"
				should have_content new_name
				should have_content new_track
			end
			
			it "creates new Scene with Characters" do
		  	new_name = Faker::Lorem.word
		  	new_track = Faker::Lorem.word
				fill_in "Scene", with: new_name
				fill_in "Track", with: new_track
				select @character.name, from: "scene_character_ids" #Label = Characters
				click_button 'Create'

				should have_selector 'div.alert-success'
				should have_title "Scenes"
				should have_content new_name
				should have_content @character.name
				should have_content new_track
			end
		end
		
		it "has links for Super Admin" do
			scene = FactoryGirl.create(:scene, account: current_account)
			visit piece_scenes_path(scene.piece)
			
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
			@scene = FactoryGirl.create(:scene, account: current_account)
			@piece = @scene.piece
	  	click_link 'Setup'
	  	click_link "Pieces"
	  	click_link @piece.name
	  	click_link "Scenes"
	  	click_link @scene.name
		end
		
		it "has correct title" do	
	  	should have_title "#{@piece.name} | Edit Scene"
		  should have_selector 'h1', text: @piece.name
			should have_selector 'h1 small', text: 'Edit Scene'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Pieces'
			should have_selector 'li.active', text: 'Scenes'
		end
		
		it "has correct fields on form" do
	    should have_field 'Scene'
	    should have_field 'Track'
	    should have_content 'Characters'	#Using Chosen
			should have_link 'Cancel', href: piece_scenes_path(@piece)
		end
		
	  it "with error shows error message" do
	  	fill_in "Scene", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "with valid info" do
			new_name = Faker::Lorem.word
			new_track = Faker::Lorem.word
			fill_in "Scene", with: new_name
			fill_in "Track", with: new_track
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title "#{@piece.name} | Scenes"
			should have_content new_name
			should have_content new_track
		end
		
		it "has links for Super Admin" do
	  	should have_link 'Overview'
	  	should have_link 'Scenes'
	  	should have_link 'Characters'
		
			should have_link 'Add Piece'
			should have_link 'Delete Piece'
			should have_link 'Add Character'
			should have_link 'Add Scene'
			should have_link 'Delete Scene'
			should have_link 'Download Scenes PDF'
		end
	end
  
  describe "#destroy" do
		before do
	  	log_in
			@scene = FactoryGirl.create(:scene, account: current_account)
			visit piece_scenes_path(@scene.piece)
			click_link "delete_#{@scene.id}"
		end
		
  	it "deletes the record" do
			should have_selector 'div.alert-success'
			should have_title "#{@scene.piece.name} | Scenes"
			
			should_not have_content @scene.name
		end
  end
  
  describe "#sort" do
		before do
  		log_in
			scene = FactoryGirl.create(:scene, account: current_account)
	  	
			click_link 'Setup'
	  	click_link "Pieces"
	  	click_link scene.piece.name
	  	click_link "Scenes"
		end
		
  	it "has sort drag handle" do
			should have_selector '.handle'
		end
  end
end
