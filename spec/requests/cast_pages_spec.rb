require 'spec_helper'

describe "Cast Pages:" do
	subject { page }
  
	context "#new" do
		it "creates new Cast for Season/Piece" do
			log_in
			season = FactoryGirl.create(:season, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			season_piece = FactoryGirl.create(:season_piece, season: season, piece: piece)
			visit season_path(season)
			
	  	click_link 'Add Cast'
			
			should have_selector('div.alert-success')
			has_title?(season.name).should be_true
			should have_content('Cast A')
			
			click_link 'Add Cast'
			should have_content('Cast B')
		end
	end
	
	context "#destroy" do
		it "deletes the record" do
	  	log_in
			season = FactoryGirl.create(:season, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			season_piece = FactoryGirl.create(:season_piece, season: season, piece: piece)
			cast = FactoryGirl.create(:cast, season_piece: season_piece)
			visit season_path(season)
			
			should have_content('Cast A')
			click_link "Delete"
			
			should have_selector('div.alert-success')
			has_title?(season.name).should be_true
			should_not have_content('Cast A')
		end
	end
end
