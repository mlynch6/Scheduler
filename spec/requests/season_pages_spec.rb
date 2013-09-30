require 'spec_helper'

describe "Season Pages:", focus: true do
	subject { page }
  
  context "#index" do
  	it "has correct title & table headers" do
  		log_in
	  	click_link "Seasons"
	  	
	  	should have_selector('title', text: 'Seasons')
		  should have_selector('h1', text: 'Seasons')
		  
		  should have_selector('th', text: "Name")
		  should have_selector('th', text: "Start Date")
		  should have_selector('th', text: "End Date")
		end
		
		it "without records" do
			log_in
	  	visit seasons_path
	  	
	    should have_selector('div.alert')
			should_not have_selector('td')
			should_not have_selector('div.pagination')
		end
	  
		it "lists records" do
			log_in
			4.times { FactoryGirl.create(:season, account: current_account) }
			visit seasons_path(per_page: 3)
	
			should have_selector('div.pagination')
			Season.paginate(page: 1, per_page: 3).each do |season|
				should have_selector('td', text: season.name)
				should have_link('View', href: season_path(season))
				should have_link('Edit', href: edit_season_path(season))
				should have_link('Delete', href: season_path(season))
	    end
		end
		
		it "doesn't have links for Employee" do
			log_in_employee
			FactoryGirl.create(:season, account: current_account)
			visit seasons_path
	
			should_not have_link('Add Season')
			should_not have_link('View')
			should_not have_link('Edit')
			should_not have_link('Delete')
		end
		
		it "has links for Administrator" do
			log_in_admin
			FactoryGirl.create(:season, account: current_account)
			visit seasons_path
	
			should have_link('Add Season')
			should have_link('View')
			should have_link('Edit')
			should have_link('Delete')
		end
	end

	context "#new" do
		it "has correct title" do
			log_in
	  	click_link "Seasons"
	  	click_link "Add Season"
	
			should have_selector('title', text: 'Add Season')
			should have_selector('h1', text: 'Add Season')
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				visit new_season_path
				click_button 'Create'
		
				should have_selector('div.alert-error')
			end
			
			it "doesn't create Season" do
				log_in
				visit new_season_path
		
				expect { click_button 'Create' }.not_to change(Season, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Season without Pieces" do
				log_in
				visit new_season_path
		  	
		  	new_name = Faker::Lorem.word
				fill_in "Name", with: new_name
				fill_in "From", with: '01/01/2011'
				fill_in "To", with: '12/31/2011'
				click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Seasons')
				should have_content(new_name)
				should have_content('01/01/2011')
				should have_content('12/31/2011')
			end
			
			it "creates new Season with Pieces" do
				log_in
				piece = FactoryGirl.create(:piece, account: current_account)
				visit new_season_path
		  	
		  	new_name = Faker::Lorem.word
				fill_in "Name", with: new_name
				fill_in "From", with: '01/01/2011'
				fill_in "To", with: '12/31/2011'
				select piece.name, from: "Pieces"
				click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Seasons')
				should have_content(new_name)
				should have_content('01/01/2011')
				should have_content('12/31/2011')
			end
		end
	end

	context "#edit" do
		it "has correct title" do
			log_in
			season = FactoryGirl.create(:season, account: current_account)
			click_link "Seasons"
	  	click_link "Edit"
	  	
	  	should have_selector('title', text: 'Edit Season')
			should have_selector('h1', text: 'Edit Season')
		end
		
	  it "record with error" do
	  	log_in
	  	season = FactoryGirl.create(:season, account: current_account)
	  	visit edit_season_path(season)
	  	fill_in "Name", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-error')
		end
	 
		it "record with valid info saves season" do
			log_in
			season = FactoryGirl.create(:season, account: current_account)
			new_name = Faker::Lorem.word
			visit seasons_path
			click_link "edit_#{season.id}"
			
			fill_in "Name", with: new_name
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Seasons')
			should have_content(new_name)
		end
	end
	
	context "#destroy" do
		it "deletes the record" do
	  	log_in
			season = FactoryGirl.create(:season, account: current_account)
			visit seasons_path
			click_link "delete_#{season.id}"
			
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Seasons')
			
			should_not have_content(season.name)
		end
	end
	
	context "#show" do
  	it "has correct title & table headers" do
  		log_in
  		season = FactoryGirl.create(:season, account: current_account)
	  	click_link "Seasons"
	  	click_link "View"
	  	
	  	should have_selector('title', text: season.name)
	  	should have_selector('title', text: 'Pieces')
		  should have_selector('h1', text: season.name)
		  
		  should have_selector('th', text: "Piece")
		  should have_selector('th', text: "Casts")
		end
		
		it "displays correct data" do
			log_in
			season = FactoryGirl.create(:season, account: current_account)
			visit season_path(season)
	  	
			should have_content(season.name)
			should have_content(season.start_dt)
			should have_content(season.end_dt)
		end
		
		it "has pieces shown" do
			log_in
			season = FactoryGirl.create(:season, account: current_account)
			3.times {
				piece = FactoryGirl.create(:piece, account: current_account)
				FactoryGirl.create(:season_piece, season: season, piece: piece)
			}
			visit season_path(season)

			season.pieces.each do |piece|
				should have_content(piece.name)
			end
		end
		
		it "has casts for pieces shown" do
			log_in
			season = FactoryGirl.create(:season, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			season_piece = FactoryGirl.create(:season_piece, season: season, piece: piece)
			3.times { FactoryGirl.create(:cast, season_piece: season_piece) }
			visit season_path(season)

			should have_content(piece.name)
			season_piece.casts.each do |cast|
				should have_content(cast.name)
				should have_link('Add Cast', href: new_season_piece_cast_path(season_piece))
				should have_link('Delete')
			end
		end
		
		it "has links for Administrator" do
			log_in_admin
			season = FactoryGirl.create(:season, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			season_piece = FactoryGirl.create(:season_piece, season: season, piece: piece)
			cast = FactoryGirl.create(:cast, season_piece: season_piece)
			visit season_path(season)
	
			should have_link('Add Cast')
			should have_link('Delete')
		end
	end
end
