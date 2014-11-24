require 'spec_helper'

describe "Lecture Demo Contract Settings Pages:" do
  subject { page }
  
	context "#edit" do
		
		before do
		  log_in
		  click_link 'Setup'
		  click_link 'Contract Settings'
			click_link 'Lecture Demos'
			click_link 'Edit Lecture Demo Settings'
		end
	
		it "has correct title" do
	  	should have_title 'Contract Settings | Edit Lecture Demos'
			should have_selector 'h1', text: 'Contract Settings'
			should have_selector 'h1 small', text: 'Edit'
		end
	
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Contract Settings'
			should have_selector 'li.active', text: 'Lecture Demos'
		end
	
		it "has correct fields on form" do
			should have_field 'Max Duration'
	    should have_field 'Max Demos/Day'
			
			should have_link 'Cancel', href: company_contract_lecture_demo_path
		end
	
	  it "with error shows error message" do
	  	fill_in "Max Duration", with: "a"
	  	click_button 'Update'

			should have_selector 'div.alert-danger'
		end
 
		it "with valid info" do
		  fill_in "Max Duration", with: 50
			fill_in "Max Demos/Day", with: 3
			click_button 'Update'

			should have_selector 'div.alert-success'
			should have_title 'Contract Settings | Lecture Demos'
			should have_content '50 minutes'
			should have_content '3 per day'
		end
	end
	
	context "#show" do
	  before do
		  log_in
		  click_link 'Setup'
		  click_link 'Contract Settings'
			click_link 'Lecture Demos'
		end
		
		it "has correct title" do
			should have_title 'Contract Settings | Lecture Demos'
			should have_selector 'h1', text: 'Contract Settings'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Contract Settings'
			should have_selector 'li.active', text: 'Lecture Demos'
		end
		
		it "displays correct data when populated" do
			contract = current_account.agma_contract
			contract.demo_max_duration = 50
			contract.demo_max_num_per_day = 3
			contract.save
			visit company_contract_lecture_demo_path
			
			should have_content "50 min"
			should have_content "3 per day"
		end
		
		it "displays NO data when NOT populated" do
			contract = current_account.agma_contract
			contract.demo_max_duration = ""
			contract.demo_max_num_per_day = ""
			contract.save
			visit company_contract_lecture_demo_path
			
			should_not have_css 'div.dtl-text', text: 'min'
			should_not have_css 'div.dtl-text', text: 'per day'
		end
		
		it "has links for Super Admin" do
			should have_link 'Edit Lecture Demo Settings'
		end
	end
end
