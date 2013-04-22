require 'spec_helper'

describe "Scene Pages:" do
  subject { page }

	context "#index" do
  	it "has correct title & table headers" do
  		log_in
  		piece = FactoryGirl.create(:piece, account: current_account)
  		FactoryGirl.create(:scene, account: current_account, piece: piece)
	  	click_link "Scheduling"
	  	click_link "Active Pieces"
	  	click_link "View"
	  	
	  	should have_selector('title', text: "#{piece.name} | Scenes")
		  should have_selector('h1', text: "Scenes for #{piece.name}")
		  
		  should have_selector('th', text: "Scene")
		  should have_selector('th', text: "Characters")
		  should have_selector('th', text: "Track")
		end
		
		it "without records" do
			log_in
			piece = FactoryGirl.create(:piece, account: current_account)
	  	visit piece_scenes_path(piece)
	  	
	    should have_selector('div.alert')
			should_not have_selector('td')
		end
	  
		it "lists records" do
			log_in
			piece = FactoryGirl.create(:piece, account: current_account)
			4.times { FactoryGirl.create(:scene, account: current_account, piece: piece) }
			visit piece_scenes_path(piece)
	
			piece.scenes.each do |scene|
				should have_selector('td', text: scene.name)
				should have_link('Edit', href: edit_scene_path(scene))
				should have_link('Delete', href: scene_path(scene))
	    end
		end
		
		it "doesn't have links for Employee" do
			log_in_employee
			piece = FactoryGirl.create(:piece, account: current_account)
			FactoryGirl.create(:scene, account: current_account, piece: piece)
			visit piece_scenes_path(piece)
	
			should_not have_link('Add Scene')
			should_not have_link('Edit')
			should_not have_link('Delete')
		end
		
		it "has links for Administrator" do
			log_in_admin
			piece = FactoryGirl.create(:piece, account: current_account)
			FactoryGirl.create(:scene, account: current_account, piece: piece)
			visit piece_scenes_path(piece)
	
			should have_link('Add Scene')
			should have_link('Edit')
			should have_link('Delete')
		end
	end
	
	context "#new" do
		it "has correct title" do
			log_in
  		piece = FactoryGirl.create(:piece, account: current_account)
  		click_link "Scheduling"
	  	click_link "Active Pieces"
	  	click_link "View"
	  	click_link "Add Scene"
	
			should have_selector('title', text: "#{piece.name} | Add Scene")
		  should have_selector('h1', text: "Add Scene for #{piece.name}")
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				piece = FactoryGirl.create(:piece, account: current_account)
				visit new_piece_scene_path(piece)
		  	click_button 'Create'
		
				should have_selector('div.alert-error')
			end
			
			it "doesn't create Piece" do
				log_in
				piece = FactoryGirl.create(:piece, account: current_account)
				visit new_piece_scene_path(piece)
		
				expect { click_button 'Create' }.not_to change(Scene, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Scene" do
				log_in
				piece = FactoryGirl.create(:piece, account: current_account)
				visit new_piece_scene_path(piece)
				
		  	new_name = Faker::Lorem.word
		  	new_track = Faker::Lorem.word
				fill_in "Name", with: new_name
				fill_in "Track", with: new_track
				click_button 'Create'

				should have_selector('div.alert-success')
				should have_selector('title', text: 'Scenes')
				should have_content(new_name)
				should have_content(new_track)
			end
		end
	end
	
	context "#edit" do
		it "has correct title" do
			log_in
			piece = FactoryGirl.create(:piece, account: current_account)
			scene = FactoryGirl.create(:scene, account: current_account, piece: piece)
  		click_link "Scheduling"
	  	click_link "Active Pieces"
	  	click_link "View"
	  	click_link "Edit"
	  	
	  	should have_selector('title', text: "#{piece.name} | Edit Scene")
		  should have_selector('h1', text: "Edit Scene for #{piece.name}")
		end
		
	  it "with error shows error message" do
	  	log_in
	  	piece = FactoryGirl.create(:piece, account: current_account)
			scene = FactoryGirl.create(:scene, account: current_account, piece: piece)
	  	visit edit_scene_path(scene)
	  	fill_in "Name", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-error')
		end
	
		it "with bad record in URL shows 'Record Not Found' error" do
			pending
			log_in
			visit edit_scene_path(0)
	
			should have_content('Record Not Found')
		end
		
		it "record with wrong account shows 'Record Not Found' error" do
			pending
			log_in
			scene_wrong_account = FactoryGirl.create(:scene)
			visit edit_scene_path(scene_wrong_account)
	
			should have_content('Record Not Found')
		end
	 
		it "with valid info" do
			log_in
			piece = FactoryGirl.create(:piece, account: current_account)
			scene = FactoryGirl.create(:scene, account: current_account, piece: piece)
	  	visit edit_scene_path(scene)
			
			new_name = Faker::Lorem.word
			new_track = Faker::Lorem.word
			fill_in "Name", with: new_name
			fill_in "Track", with: new_track
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: "#{piece.name} | Scenes")
			should have_content(new_name)
			should have_content(new_track)
		end
	end
  
  describe "#destroy" do
  	it "deletes the record" do
	  	log_in
			piece = FactoryGirl.create(:piece, account: current_account)
			scene = FactoryGirl.create(:scene, account: current_account, piece: piece)
			visit piece_scenes_path(piece)
			click_link "delete_#{scene.id}"
			
			should have_selector('div.alert-success')
			should have_selector('title', text: "#{piece.name} | Scenes")
			
			should_not have_content(scene.name)
		end
  end
end
