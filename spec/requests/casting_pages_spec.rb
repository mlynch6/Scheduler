require 'spec_helper'

describe "Casting Pages:" do
  subject { page }

	before do
		log_in
		@person = FactoryGirl.create(:person, account: current_account)
		@season = FactoryGirl.create(:season, account: current_account)
  	@piece = FactoryGirl.create(:piece, account: current_account)
		Account.current_id = current_account.id
		@character = @piece.characters.create(name: Faker::Name.name)
		@sp = FactoryGirl.create(:season_piece, account: current_account, season: @season, piece: @piece)
		@cast = FactoryGirl.create(:cast, account: current_account, season_piece: @sp)
	end
	
	context "#edit" do
		before do
			click_link 'Setup'
			click_link 'Seasons'
			click_link @season.name
			click_link 'pieces-tab-link'
			click_link 'View Casts'
			click_link @cast.name
			click_link 'Edit'
		end
		
		it "has correct title" do
			should have_title "#{@season.name} | #{@piece.name} | Edit #{@cast.name}"
			should have_selector 'h1', text: "Edit #{@cast.name} for #{@piece.name}"
			should have_selector 'h1 small', text: @season.name
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Seasons'
		end
		
		it "has correct fields on form" do
			should have_content "#{@character.name}"
			should have_field 'Artist'	#Using Chosen
			should have_link 'Cancel', href: season_piece_cast_path(@sp, @cast)
		end
		
	  it "with error shows error message" do
			pending "No fields will cause error on form"
	  	select '', from: 'Artist'
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "with valid info", js: true do
			select_from_chosen @person.full_name, from: 'Artist'
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title "#{@season.name} | #{@piece.name} | #{@cast.name}"
			should have_content @person.full_name
		end
	end
end
