require 'spec_helper'

describe "Season Pages:" do
	subject { page }
  
  context "#index" do
		before do
  		log_in
  		click_link "Setup"
	  	click_link "Seasons"
		end
		
  	it "has correct title" do	
	  	should have_title 'Seasons'
		  should have_selector 'h1', text: 'Seasons'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Seasons'
		end
		
		it "without records" do
	    should have_selector 'p', text: 'To begin'
			should_not have_selector 'td'
			should_not have_selector 'div.pagination'
		end
	  
		it "lists records" do
			4.times { FactoryGirl.create(:season, account: current_account) }
			visit seasons_path(per_page: 3)
	
			should have_selector 'th', text: "Name"
		  should have_selector 'th', text: "Start Date"
		  should have_selector 'th', text: "End Date"
			should have_selector 'div.pagination'
			
			Season.paginate(page: 1, per_page: 3).each do |season|
				should have_selector 'td', text: season.name
				should have_link season.name, href: season_path(season)
				should have_link 'Delete', href: season_path(season)
	    end
		end
		
		it "has links for Super Admin" do
			@season = FactoryGirl.create(:season, account: current_account)
			visit seasons_path
	
			should have_link 'Add Season'
			should have_link @season.name
			should have_link 'Delete'
		end
	end

	context "#new" do
		before do
			log_in
			@piece = FactoryGirl.create(:piece, account: current_account)
			click_link "Setup"
	  	click_link "Seasons"
	  	click_link "Add Season"
		end
		
		it "has correct title" do
			should have_title 'Add Season'
			should have_selector 'h1', text: 'Seasons'
			should have_selector 'h1 small', text: 'Add'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Seasons'
		end
		
		it "has correct fields on form" do
			should have_field 'Name'
			should have_field 'From'
	    should have_field 'To'
	    should have_content 'Pieces'	#Using Chosen
			should have_link 'Cancel', href: seasons_path
		end
		
		context "with error" do
			it "shows error message" do
				click_button 'Create'
		
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Season" do
				expect { click_button 'Create' }.not_to change(Season, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Season without Pieces" do
		  	new_name = Faker::Lorem.word
				fill_in "Name", with: new_name
				fill_in "From", with: '01/01/2011'
				fill_in "To", with: '12/31/2011'
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Seasons'
				should have_content new_name
				should have_content '01/01/2011'
				should have_content '12/31/2011'
			end
			
			it "creates new Season with Pieces" do
		  	new_name = Faker::Lorem.word
				fill_in "Name", with: new_name
				fill_in "From", with: '01/01/2011'
				fill_in "To", with: '12/31/2011'
				select @piece.name, from: "Pieces"
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Seasons'
				should have_content new_name
				should have_content '01/01/2011'
				should have_content '12/31/2011'
			end
		end
		
		it "has links for Super Admin" do
			should have_link 'Add Season'
		end
	end

	context "#edit" do
		before do
			log_in
			@season = FactoryGirl.create(:season, account: current_account)
			click_link "Setup"
			click_link "Seasons"
	  	click_link @season.name
			click_link @season.name
		end
		
		it "has correct title" do
	  	should have_title 'Edit Season'
			should have_selector 'h1', text: 'Seasons'
			should have_selector 'h1 small', text: 'Edit'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Seasons'
			#should have_selector 'li.active', text: 'Overview'
		end
		
		it "has correct fields on form" do
			should have_field 'Name'
			should have_field 'From'
	    should have_field 'To'
	    should have_content 'Pieces'	#Using Chosen
			should have_link 'Cancel', href: season_path(@season)
		end
		
	  it "record with error" do
	  	fill_in "Name", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "record with valid info saves season" do
			new_name = Faker::Lorem.word
			
			fill_in "Name", with: new_name
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Seasons'
			should have_content new_name
		end
		
		it "has links for Super Admin" do
			should have_link 'Add Season'
			should have_link 'Delete Season'
		end
	end
	
	context "#destroy" do
		before do
	  	log_in
			@season = FactoryGirl.create(:season, account: current_account)
			visit seasons_path
			click_link "delete_#{@season.id}"
		end
		
		it "deletes the record" do
			should have_selector 'div.alert-success'
			should have_title 'Seasons'
			
			should_not have_content @season.name
		end
	end
	
	context "#show" do
		before do
  		log_in
  		@season = FactoryGirl.create(:season, account: current_account)
			@season_piece = FactoryGirl.create(:season_piece, account: current_account, season: @season)
			@castA = FactoryGirl.create(:cast, account: current_account, season_piece: @season_piece)
			
	  	click_link 'Setup'
	  	click_link 'Seasons'
	  	click_link @season.name
		end
		
  	it "has correct title" do
	  	should have_title @season.name
		  should have_selector 'h1', text: @season.name
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Seasons'
			should have_selector 'li.active', text: 'Overview'
		end
		
		it "displays correct data" do
			should have_content @season.name
			should have_content @season.start_dt
			should have_content @season.end_dt
		end
		
		it "displays associated pieces", js: true do
			2.times {
				FactoryGirl.create(:season_piece, account: current_account, season: @season)
			}
			visit season_path(@season)
			click_link 'pieces-tab-link'
		  
			@season.pieces.each do |piece|
				should have_content piece.name
			end
		end
		
		it "displays cast count for each associated piece" do
			should have_content @season_piece.piece.name
			should have_selector 'td', text: "Casts"
			should have_selector 'span.badge', text: "1"
		end
		
		it "has links for Super Admin" do
			should have_link @season.name
			should have_link 'View Casts'
			
			should have_link 'Overview'
			should have_link 'Pieces'
			
			should have_link 'Add Season'
			should have_link 'Delete Season'
		end
	end
end
