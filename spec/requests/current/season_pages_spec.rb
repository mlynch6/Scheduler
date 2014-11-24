require 'spec_helper'

describe "Current Season Pages:" do
  subject { page }
	
	context "#new" do
		before do
			log_in
			@season = FactoryGirl.create(:season, account: current_account)
			click_link 'Set Current Season'
		end
		
		it "has correct title" do
			should have_title 'Set Current Season'
			should have_selector 'h1', text: 'Current Season'
			should have_selector 'h1 small', text: 'Set'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Home'
		end
		
		it "has correct fields on form" do
	    should have_select 'Season'
			should have_link 'Cancel', href: dashboard_path
		end
		
		it "updates the session with the seleted season" do
			select @season.name, from: "Season"
			click_button "Set"
		  
			should have_selector 'div.alert-success'
		  should have_title 'Dashboard'
			should have_content @season.name
		end
	end
end
