require 'spec_helper'

describe "Rehearsal Week Contract Settings Pages:" do
  subject { page }
  
	context "#edit" do
		before do
		  log_in
		  click_link 'Setup'
		  click_link 'Contract Settings'
			click_link 'Rehearsal Week'
			click_link 'Edit Rehearsal Week Settings'
		end
	
		it "has correct title" do
	  	should have_title 'Contract Settings | Edit Rehearsal Week'
			should have_selector 'h1', text: 'Contract Settings'
			should have_selector 'h1 small', text: 'Edit'
		end
	
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Contract Settings'
			should have_selector 'li.active', text: 'Rehearsal Week'
		end
	
		it "has correct fields on form" do
			should have_select 'Rehearsal Start'
			should have_select 'Rehearsal End'
			should have_field 'Max Hours/Week'
			should have_field 'Max Hours/Day'
			should have_field 'Rehearsal Increments'
			
			should have_link 'Cancel', href: company_contract_rehearsal_week_path
		end
	
	  it "with error shows error message" do
	  	fill_in "Max Hours/Week", with: "a"
	  	click_button 'Update'

			should have_selector 'div.alert-danger'
		end
 
		it "with valid info" do
		  fill_in "Max Hours/Week", with: 40
			click_button 'Update'

			should have_selector 'div.alert-success'
			should have_title 'Contract Settings | Rehearsal Week'
		end
	end
	
	context "#show" do
	  before do
		  log_in
			current_account.agma_contract.rehearsal_start_min = 540
			current_account.agma_contract.rehearsal_end_min = 1080
			current_account.agma_contract.rehearsal_max_hrs_per_week = 30
			current_account.agma_contract.rehearsal_max_hrs_per_day = 6
			current_account.agma_contract.rehearsal_increment_min = 15
			current_account.agma_contract.save
		  click_link 'Setup'
		  click_link 'Contract Settings'
			click_link 'Rehearsal Week'
		end
		
		it "has correct title" do
			should have_title 'Contract Settings | Rehearsal Week'
			should have_selector 'h1', text: 'Contract Settings'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Contract Settings'
			should have_selector 'li.active', text: 'Rehearsal Week'
		end
		
		it "displays correct data" do
			should have_content "9:00 AM"
			should have_content "6:00 PM"
			should have_content "30 hours/week"
			should have_content "6 hours/day"
			should have_content "15 minutes"
		end
		
		describe "displays correct Rehearsal Break data" do
			it "without records" do
		    should have_selector 'p', text: 'To begin'
				should_not have_selector 'td'
			end
			
			it "with records" do
				@break60 = FactoryGirl.create(:rehearsal_break, 
							agma_contract: current_account.agma_contract,
							duration_min: 60,
							break_min: 5)		
				click_link "Rehearsal Week"
				
				should have_content "60 min rehearsal"
				should have_content "5 min break"
			end
		end
		
		it "has links for Super Admin" do
			should have_link 'Edit Rehearsal Week Settings'
			should have_link 'Add Rehearsal Break'
		end
	end
end
