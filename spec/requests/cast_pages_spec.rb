require 'spec_helper'

describe "Cast Pages:" do
	subject { page }

	before do
		log_in
		@season = FactoryGirl.create(:season, account: current_account)
		@piece = FactoryGirl.create(:piece, account: current_account)
		@season_piece = FactoryGirl.create(:season_piece, account: current_account, season: @season, piece: @piece)
	end
	
	context "#index" do
		before do
			@char1 = FactoryGirl.create(:character, account: current_account, piece: @piece)
			@char2 = FactoryGirl.create(:character, account: current_account, piece: @piece)
			
  		click_link 'Setup'
	  	click_link 'Seasons'
			click_link @season.name
			click_link 'pieces-tab-link'
			click_link 'View Casts'
		end
		
  	it "has correct title" do
	  	should have_title "#{@season.name} | #{@piece.name} | Casting"
		  should have_selector 'h1', text: "Casting for #{@piece.name}"
			should have_selector 'h1 small', text: @season.name
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Seasons'
		end
		
		it "without records" do
	    should have_selector 'p', text: 'To begin'
			should_not have_selector 'td'
		end
	  
		it "lists records" do
			@castA = FactoryGirl.create(:cast, account: current_account, season_piece: @season_piece)
			visit season_piece_casts_path(@season_piece)
	
			should have_selector 'th', text: @castA.name
			should have_link @castA.name, href: season_piece_cast_path(@season_piece, @castA)
			should have_link 'Delete'
			
			@castA.castings.each do |casting|
				should have_selector 'td', text: casting.character.name
				should have_selector 'td', text: casting.person.full_name
	    end
		end
		
		it "shows Male gender on list" do
			@char = FactoryGirl.create(:character, :male, account: current_account, piece: @piece)
			@cast = FactoryGirl.create(:cast, account: current_account, season_piece: @season_piece)
			FactoryGirl.create(:casting, account: current_account, cast: @cast, character: @char)
			visit season_piece_casts_path(@season_piece)
	
			should have_selector 'td', text: 'M'
		end
		
		it "shows Female gender on list" do
			@char = FactoryGirl.create(:character, :female, account: current_account, piece: @piece)
			@cast = FactoryGirl.create(:cast, account: current_account, season_piece: @season_piece)
			FactoryGirl.create(:casting, account: current_account, cast: @cast, character: @char)
			visit season_piece_casts_path(@season_piece)
	
			should have_selector 'td', text: 'F'
		end
		
		it "shows Animal on list" do
			@char = FactoryGirl.create(:character, :animal, account: current_account, piece: @piece)
			@cast = FactoryGirl.create(:cast, account: current_account, season_piece: @season_piece)
			FactoryGirl.create(:casting, account: current_account, cast: @cast, character: @char)
			visit season_piece_casts_path(@season_piece)
	
			should have_selector 'td', text: 'A'
		end
		
		it "shows Child on list" do
			@char = FactoryGirl.create(:character, :child, account: current_account, piece: @piece)
			@cast = FactoryGirl.create(:cast, account: current_account, season_piece: @season_piece)
			FactoryGirl.create(:casting, account: current_account, cast: @cast, character: @char)
			visit season_piece_casts_path(@season_piece)
	
			should have_selector 'td', text: 'K'
		end
		
		it "shows Speaking Role on list" do
			@char = FactoryGirl.create(:character, :speaking, account: current_account, piece: @piece)
			@cast = FactoryGirl.create(:cast, account: current_account, season_piece: @season_piece)
			FactoryGirl.create(:casting, account: current_account, cast: @cast, character: @char)
			visit season_piece_casts_path(@season_piece)
	
			should have_selector 'span.glyphicon-bullhorn'
		end
		
		it "has links for Super Admin" do
			should have_link 'Add Cast'
			should have_link 'Publish Casting'
			should have_link 'Download PDF'
		end
	end
	
	context "#new" do
		before do
			click_link 'Setup'
	  	click_link 'Seasons'
			click_link @season.name
			click_link 'pieces-tab-link'
			click_link 'View Casts'
			click_link 'Add Cast'
		end
		
		it "creates new Cast for Season/Piece" do
			should have_selector 'div.alert-success'
			should have_title "#{@season.name} | #{@piece.name} | Casting"
			should have_content 'Cast A'
			
			click_link 'Add Cast'
			should have_content 'Cast B'
		end
	end
	
	context "#destroy" do
		it "deletes the record" do
			cast = FactoryGirl.create(:cast, account: current_account, season_piece: @season_piece)
			visit season_piece_casts_path(@season_piece)
			
			should have_content 'Cast A'
			click_link 'Delete'
			
			should have_selector 'div.alert-success'
			should have_title "#{@season.name} | #{@piece.name} | Casting"
			should_not have_content 'Cast A'
		end
	end
	
	context "#show" do
		before do
			@char1 = FactoryGirl.create(:character, account: current_account, piece: @piece)
			@char2 = FactoryGirl.create(:character, account: current_account, piece: @piece)
			@cast = FactoryGirl.create(:cast, account: current_account, season_piece: @season_piece)
			FactoryGirl.create(:casting, :with_person, account: current_account, cast: @cast, character: @char1)
			FactoryGirl.create(:casting, account: current_account, cast: @cast, character: @char2)
			
			click_link 'Setup'
			click_link 'Seasons'
			click_link @season.name
			click_link 'pieces-tab-link'
			click_link 'View Casts'
			click_link @cast.name
		end
		
		it "has correct title" do
	  	should have_title "#{@season.name} | #{@piece.name} | #{@cast.name}"
			should have_selector 'h1', text: "#{@cast.name} for #{@piece.name}"
			should have_selector 'h1 small', text: "#{@season.name}"
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Seasons'
		end
		
		it "displays correct data" do
			Account.current_id = current_account.id
			@cast.castings.count.should > 0
			@cast.castings.each do |casting|
				should have_selector 'td', text: casting.character.name
				if casting.person.present?
					should have_selector 'td', text: casting.person.full_name
				else
					should have_selector 'td', text: 'TBD'
				end
			end
		end
		
		it "has links for Super Admin" do
			Account.current_id = current_account.id
			@cast.castings.count.should > 0
			@cast.castings.each do |casting|
				should have_link "edit_#{casting.id}"
			end
			
			should have_link 'Delete Cast'
		end
	end
end
