require 'spec_helper'

describe "Rehearsal Pages:" do
	subject { page }
  
  context "#new" do
  	it "has correct title" do
			log_in
	  	visit events_path
	  	click_link 'New Rehearsal'
	  	
	  	should have_selector('title', text: 'New Rehearsal')
		  should have_selector('h1', text: 'New Rehearsal')
		end
		
		it "has only active Locations in dropdown" do
			log_in
			FactoryGirl.create(:location, account: current_account, name: 'Location A')
			FactoryGirl.create(:location_inactive, account: current_account, name: 'Location B')
			visit new_rehearsal_path
  		
			should have_selector('option', text: 'Location A')
			should_not have_selector('option', text: 'Location B')
		end
		
		it "has only active Pieces in dropdown" do
			log_in
			FactoryGirl.create(:piece, account: current_account, name: 'Piece A')
			FactoryGirl.create(:piece_inactive, account: current_account, name: 'Piece B')
			visit new_rehearsal_path
  		
			should have_selector('option', text: 'Piece A')
			should_not have_selector('option', text: 'Piece B')
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				visit new_rehearsal_path
		  	click_button 'Create'
		
				should have_selector('div.alert-error')
			end
			
			it "doesn't create Rehearsal" do
				log_in
				visit events_path
	  		click_link 'New Rehearsal'
		
				expect { click_button 'Create' }.not_to change(Rehearsal, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Rehearsal" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				visit events_path
	  		click_link 'New Rehearsal'
	  		
		  	fill_in "Title", with: "Test Rehearsal"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2012"
		  	fill_in 'From', with: "9AM"
		  	fill_in 'rehearsal_end_time', with: "11:30AM"
		  	select piece.name, from: "Piece"
				click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Events')
				
				should have_content("Test Rehearsal")
				should have_content(location.name)
				should have_content("9:00 AM")
				should have_content("11:30 AM")
				should have_content(piece.name)
			end
		end
	end
end
