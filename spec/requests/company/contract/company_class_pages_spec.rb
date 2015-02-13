require 'spec_helper'

describe "Company Class Contract Settings Pages:" do
  subject { page }
  
	context "#edit" do
		
		before do
		  log_in
		  click_link 'Setup'
		  click_link 'Contract Settings'
			click_link 'Company Class'
			click_link 'Edit Company Class Settings'
		end
	
		it "has correct title" do
	  	should have_title 'Contract Settings | Edit Company Class'
			should have_selector 'h1', text: 'Contract Settings'
			should have_selector 'h1 small', text: 'Edit'
		end
	
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Contract Settings'
			should have_selector 'li.active', text: 'Company Class'
		end
	
		it "has correct fields on form" do
			should have_field 'Class Break'
			
			should have_link 'Cancel', href: company_contract_company_class_path
		end
	
	  it "with error shows error message" do
	  	fill_in "Class Break", with: "a"
	  	click_button 'Update'

			should have_selector 'div.alert-danger'
		end
 
		it "with valid info" do
		  fill_in "Class Break", with: 15
			click_button 'Update'

			should have_selector 'div.alert-success'
			should have_title 'Contract Settings | Company Class'
		end
	end
	
	context "#show" do
	  before do
		  log_in
			current_account.agma_contract.class_break_min = 15
			current_account.agma_contract.save
		  click_link 'Setup'
		  click_link 'Contract Settings'
			click_link 'Company Class'
		end
		
		it "has correct title" do
			should have_title 'Contract Settings | Company Class'
			should have_selector 'h1', text: 'Contract Settings'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Contract Settings'
			should have_selector 'li.active', text: 'Company Class'
		end
		
		it "displays correct data" do
			should have_content "15 minutes"
		end
		
		it "has links for Super Admin" do
			should have_link 'Edit Company Class Settings'
		end
	end
end
