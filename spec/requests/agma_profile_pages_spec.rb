require 'spec_helper'

describe "Agma Profile Pages:" do
  subject { page }
	
	context "#edit" do
		before do
			log_in
			click_link "Rehearsal Week Settings"
			click_link "Edit"
		end
		
		it "has correct title" do
	  	should have_selector('title', text: 'Edit Rehearsal Week Settings')
			should have_selector('h1', text: 'Edit Rehearsal Week Settings')
		end
		
	  it "invalid record shows error" do
	  	fill_in "Max Hours/Week", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-error')
		end
	 
		it "valid record saves profile" do
			select  "8:30 AM", from: "Rehearsal Start"
			select  "5:30 PM", from: "Rehearsal End"
			fill_in "Max Hours/Week", with: 40
    	fill_in "Max Hours/Day", with: 8
    	fill_in "Rehearsal Increments", with: 15
    	fill_in "Class Break", with: 30
    	fill_in "Rehearsal Break", with: 10
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Rehearsal Week Settings')
			should have_content('8:30 AM')
			should have_content('5:30 PM')
			should have_content('40 hours/week')
			should have_content('8 hours/day')
			should have_content('15 minutes')
			should have_content('30 minutes')
			should have_content('10 minutes')
		end
	end
	
	context "#show" do
		before do
			log_in
			click_link "Rehearsal Week Settings"
		end
		
		it "has correct title" do
	  	should have_selector('title', text: 'Rehearsal Week Settings')
			should have_selector('h1', text: 'Rehearsal Week Settings')
		end
		
		it "has links" do
	  	should have_link('Edit')
		end
		
		it "displays correct data" do
			should have_selector('div.text-ui', text: "9:00 AM")
			should have_selector('div.text-ui', text: "6:00 PM")
			should have_selector('div.text-ui', text: "30 hours/week")
			should have_selector('div.text-ui', text: "6 hours/day")
			should have_selector('div.text-ui', text: "30 minutes")
			should have_selector('div.text-ui', text: "15 minutes")
			should have_selector('div.text-ui', text: "5 minutes/Hour Rehearsal")
		end
	end
end
