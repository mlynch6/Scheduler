require 'spec_helper'

describe "Agma Profile Pages:" do
  subject { page }
	
	context "#edit" do
		it "has correct title" do
			log_in
			click_link "Settings"
			click_link "Rehearsal Weeks"
	  	
	  	should have_selector('title', text: 'Rehearsal Week Settings')
			should have_selector('h1', text: 'Rehearsal Week Settings')
		end
		
	  it "record with error" do
	  	log_in
			visit edit_agma_profile_path(current_account)
	  	fill_in "Max Hours/Week", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-error')
		end
	
		it "with bad record in URL shows current account" do
			pending
			log_in
			visit edit_agma_profile_path(0)
	
			should have_selector('title', text: 'Rehearsal Week Settings')
			should have_content(current_account.name)
		end
		
		it "record with wrong account shows current account" do
			pending
			wrong_account = FactoryGirl.create(:account)
			log_in
			visit edit_agma_profile_path(agma_profile)
	
			should have_selector('title', text: 'Rehearsal Week Settings')
			should have_content(current_account.name)
		end
	 
		it "record with valid info saves profile" do
			log_in
			click_link "Settings"
			click_link "Rehearsal Weeks"
			select  "8:30 AM", from: "Rehearsal Start"
			select  "5:30 PM", from: "Rehearsal End"
			fill_in "Max Hours/Week", with: 40
    	fill_in "Max Hours/Day", with: 8
    	fill_in "Rehearsal Increments", with: 15
    	fill_in "Class Break", with: 30
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Settings')
			should have_selector('div.text-ui', text: '8:30 AM')
			should have_selector('div.text-ui', text: '5:30 PM')
			should have_selector('div.text-ui', text: '40 hours/week')
			should have_selector('div.text-ui', text: '8 hours/day')
			should have_selector('div.text-ui', text: '15 minutes')
			should have_selector('div.text-ui', text: '30 minutes')
		end
	end
end
