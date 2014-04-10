require 'spec_helper'

describe "Agma Contract Pages:" do
  subject { page }
  
  before do
	  log_in
	  click_link "Setup"
	  click_link "Contract Settings"
	end
	
	context "#edit" do
		before do
			click_link "Edit"
		end
		
		it "has correct title" do
			should have_title 'Edit Contract Settings'
			should have_selector 'h1', text: 'Edit Contract Settings'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Contract Settings'
		end
		
		context "has correct fields on", js: true do
			it "Rehearsal Week tab" do
				click_link 'Rehearsal Week'
				
				should have_select 'Rehearsal Start'
				should have_select 'Rehearsal End'
				should have_field 'Max Hours/Week'
				should have_field 'Max Hours/Day'
				should have_field 'Rehearsal Increments'
		    
		    should_not have_field 'Class Break'
		    
		    should_not have_field 'Costume Fitting Increments'
			end
			
			it "Company Class tab" do
				click_link 'Company Class'
				
				should_not have_select 'Rehearsal Start'
				should_not have_select 'Rehearsal End'
				should_not have_field 'Max Hours/Week'
				should_not have_field 'Max Hours/Day'
				should_not have_field 'Rehearsal Increments'
					
				should have_field 'Class Break'
				
				should_not have_field 'Costume Fitting Increments'
			end
			
			it "Costume Fitting tab" do
				click_link 'Costume Fittings'
				
				should_not have_select 'Rehearsal Start'
				should_not have_select 'Rehearsal End'
				should_not have_field 'Max Hours/Week'
				should_not have_field 'Max Hours/Day'
				should_not have_field 'Rehearsal Increments'
					
				should_not have_field 'Class Break'
				
				should have_field 'Costume Fitting Increments'
			end
		end
		
	  it "invalid record shows error" do
			fill_in "Max Hours/Week", with: ""
			click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "valid record saves contract" do
			select  "8:30 AM", from: "Rehearsal Start"
			select  "5:30 PM", from: "Rehearsal End"
			fill_in "Max Hours/Week", with: 40
			fill_in "Max Hours/Day", with: 8
			fill_in "Rehearsal Increments", with: 15
			fill_in "Class Break", with: 30
			fill_in "Costume Fitting Increments", with: 20
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Contract Settings'
			
			should have_content '8:30 AM'
			should have_content '5:30 PM'
			should have_content '40 hours/week'
			should have_content '8 hours/day'
			should have_content '15 minutes'
			should have_content '30 minutes'
			should have_content '20 minutes'
		end
	end
	
	context "#show" do
		it "has correct title" do
			should have_title 'Contract Settings'
			should have_selector 'h1', text: 'Contract Settings'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Contract Settings'
		end
		
		context "has correct fields on", js: true do
			it "Rehearsal Week tab" do
				click_link 'Rehearsal Week'
				
				should have_selector 'div.dtl-label', text: 'Rehearsal Start'
				should have_selector 'div.dtl-label', text: 'Rehearsal End'
				should have_selector 'div.dtl-label', text: 'Max Hours/Week'
				should have_selector 'div.dtl-label', text: 'Max Hours/Day'
				should have_selector 'div.dtl-label', text: 'Rehearsal Increments'
				should have_selector 'h3', text: 'Rehearsal Breaks'
				
				should_not have_selector 'div.dtl-label', text: 'Class Break'
				
				should_not have_selector 'div.dtl-label', text: 'Costume Fitting Increments'
			end
			
			it "Rehearsal Week tab for Rehearsal Breaks" do
				click_link 'Rehearsal Week'
					
				should have_selector 'h3', text: 'Rehearsal Breaks'
				should have_link 'Add Rehearsal Break'
			end
			
			it "Company Class tab" do
				click_link 'Company Class'
				
				should_not have_selector 'div.dtl-label', text: 'Rehearsal Start'
				should_not have_selector 'div.dtl-label', text: 'Rehearsal End'
				should_not have_selector 'div.dtl-label', text: 'Max Hours/Week'
				should_not have_selector 'div.dtl-label', text: 'Max Hours/Day'
				should_not have_selector 'div.dtl-label', text: 'Rehearsal Increments'
				should_not have_selector 'h3', text: 'Rehearsal Breaks'
				
				should have_selector 'div.dtl-label', text: 'Class Break'
				
				should_not have_selector 'div.dtl-label', text: 'Costume Fitting Increments'
			end
			
			it "Costume Fitting tab" do
				click_link 'Costume Fittings'
				
				should_not have_selector 'div.dtl-label', text: 'Rehearsal Start'
				should_not have_selector 'div.dtl-label', text: 'Rehearsal End'
				should_not have_selector 'div.dtl-label', text: 'Max Hours/Week'
				should_not have_selector 'div.dtl-label', text: 'Max Hours/Day'
				should_not have_selector 'div.dtl-label', text: 'Rehearsal Increments'
				should_not have_selector 'h3', text: 'Rehearsal Breaks'
				
				should_not have_selector 'div.dtl-label', text: 'Class Break'
				
				should have_selector 'div.dtl-label', text: 'Costume Fitting Increments'
			end
		end
		
		it "has links" do
			should have_link 'Edit'
		end
		
		it "displays correct Contract data" do
			should have_content "9:00 AM"
			should have_content "6:00 PM"
			should have_content "30 hours/week"
			should have_content "6 hours/day"
			should have_content "30 minutes"
			should have_content "15 minutes"
			should have_content "15 minutes"
		end
		
		it "displays correct Rehearsal Break data" do
			@break60 = FactoryGirl.create(:rehearsal_break, 
						agma_contract: current_account.agma_contract,
						duration_min: 60,
						break_min: 5)
						
			click_link "Contract Settings"
			should have_content "60 min rehearsal"
			should have_content "5 min break"
		end
	end
end
