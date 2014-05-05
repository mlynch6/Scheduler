require 'spec_helper'

describe "Publish Cast Pages:" do
	subject { page }

	before do
		log_in
		@season = FactoryGirl.create(:season, account: current_account)
		@piece = FactoryGirl.create(:piece, account: current_account)
		@season_piece = FactoryGirl.create(:season_piece, account: current_account, season: @season, piece: @piece)
		@cast = FactoryGirl.create(:cast, account: current_account, season_piece: @season_piece)
		
		click_link 'Setup'
  	click_link 'Seasons'
		click_link 'View'
		click_link 'View Casts'
		click_link 'Publish Casting'
	end
	
	context "#update" do
		it "shows published date/time" do
			should have_selector 'div.alert-success'
			should have_title "#{@season.name} | #{@piece.name} | Casting"
			
			should have_selector 'small', text: @season_piece.published_at #.to_s(:full)
		end
	end
end
