require 'spec_helper'

describe "Casting Pages:" do
  subject { page }

	before do
		log_in
		@employee = FactoryGirl.create(:employee, account: current_account)
		@season = FactoryGirl.create(:season, account: current_account)
  	@piece = FactoryGirl.create(:piece, account: current_account)
		@character = FactoryGirl.create(:character, account: current_account, piece: @piece)
		@sp = FactoryGirl.create(:season_piece, season: @season, piece: @piece)
		@cast = FactoryGirl.create(:cast, season_piece: @sp)
		@casting = FactoryGirl.create(:casting, account: current_account, cast: @cast, character: @character)
	end
	
	context "#edit" do
		let!(:char) { FactoryGirl.create(:character, account: current_account, piece: @piece) }
		before do
			click_link 'Setup'
			click_link 'Seasons'
			click_link 'View'
			click_link 'View Cast'
			click_link 'Edit'
		end
		
		it "has correct title" do
			should have_title "#{@season.name} | #{@piece.name} | #{@cast.name} | Edit Cast"
			should have_selector 'h1', text: "Edit #{@cast.name} for #{@piece.name}"
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Seasons'
		end
		
		it "has correct fields on form" do
			should have_content "#{@character.name}"
			should have_field 'Artist'	#Using Chosen
		end
		
	  it "with error shows error message" do
			pending "No fields will cause error on form"
	  	select '', from: 'Artist'
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "with valid info", js: true do
			select_from_chosen @employee.full_name, from: 'Artist'
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title "#{@season.name} | #{@piece.name} | #{@cast.name}"
			should have_content @employee.full_name
		end
	end
end
