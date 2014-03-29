require 'spec_helper'

describe "Agma Profile Pages:" do
  subject { page }
	
	context "#edit" do
		before do
			log_in
			click_link "Setup"
			click_link "Contract Settings"
			click_link "Edit"
		end
		
		it "has correct title" do
	  	has_title?('Edit Contract Settings').should be_true
			should have_selector('h1', text: 'Edit Contract Settings')
		end
		
		it "has correct Navigation" do
			should have_selector('li.active', text: 'Setup')
			should have_selector('li.active', text: 'Contract Settings')
		end
		
		it "has correct fields on form" do
			has_select?('Rehearsal Start').should be_true
	    has_select?('Rehearsal End').should be_true
	    has_field?('Max Hours/Week').should be_true
	    has_field?('Max Hours/Day').should be_true
	    has_field?('Rehearsal Increments').should be_true
	    
	    has_field?('Class Break').should be_true
	    has_field?('Rehearsal Break').should be_true
	    
	    has_field?('Costume Fitting Increments').should be_true
		end
		
	  it "invalid record shows error" do
	  	fill_in "Max Hours/Week", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-danger')
		end
	 
		it "valid record saves profile" do
			select  "8:30 AM", from: "Rehearsal Start"
			select  "5:30 PM", from: "Rehearsal End"
			fill_in "Max Hours/Week", with: 40
    	fill_in "Max Hours/Day", with: 8
    	fill_in "Rehearsal Increments", with: 15
    	fill_in "Class Break", with: 30
    	fill_in "Rehearsal Break", with: 10
    	fill_in "Costume Fitting Increments", with: 20
			click_button 'Update'
	
			should have_selector('div.alert-success')
			has_title?('Contract Settings').should be_true
			
			should have_content('8:30 AM')
			should have_content('5:30 PM')
			should have_content('40 hours/week')
			should have_content('8 hours/day')
			should have_content('15 minutes')
			should have_content('30 minutes')
			should have_content('10 minutes')
			should have_content('20 minutes')
		end
	end
	
	context "#show" do
		before do
			log_in
			click_link "Setup"
			click_link "Contract Settings"
		end
		
		it "has correct title" do
	  	has_title?('Contract Settings').should be_true
			should have_selector('h1', text: 'Contract Settings')
		end
		
		it "has correct Navigation" do
			should have_selector('li.active', text: 'Setup')
			should have_selector('li.active', text: 'Contract Settings')
		end
		
		it "has links" do
	  	should have_link('Edit')
		end
		
		it "displays correct data" do
			should have_content("9:00 AM")
			should have_content("6:00 PM")
			should have_content("30 hours/week")
			should have_content("6 hours/day")
			should have_content("30 minutes")
			should have_content("15 minutes")
			should have_content("5 minutes/Hour Rehearsal")
			should have_content("15 minutes")
		end
	end
end
