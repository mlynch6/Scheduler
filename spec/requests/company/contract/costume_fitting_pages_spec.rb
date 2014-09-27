require 'spec_helper'

describe "Costume Fitting Contract Settings Pages:" do
  subject { page }
  
	context "#edit" do
		
		before do
		  log_in
		  click_link 'Setup'
		  click_link 'Contract Settings'
			click_link 'Costume Fittings'
			click_link 'Edit Costume Fitting Settings'
		end
	
		it "has correct title" do
	  	should have_title 'Contract Settings | Edit Costume Fittings'
			should have_selector 'h1', text: 'Contract Settings'
			should have_selector 'h1 small', text: 'Edit'
		end
	
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Contract Settings'
			should have_selector 'li.active', text: 'Costume Fittings'
		end
	
		it "has correct fields on form" do
			should have_field 'Costume Fitting Increments'
			
			should have_link 'Cancel', href: company_contract_costume_fitting_path
		end
	
	  it "with error shows error message" do
	  	fill_in "Costume Fitting Increments", with: "a"
	  	click_button 'Update'

			should have_selector 'div.alert-danger'
		end
 
		it "with valid info" do
		  fill_in "Costume Fitting Increments", with: 30
			click_button 'Update'

			should have_selector 'div.alert-success'
			should have_title 'Contract Settings | Costume Fittings'
		end
	end
	
	context "#show" do
	  before do
		  log_in
		  click_link 'Setup'
		  click_link 'Contract Settings'
			click_link 'Costume Fittings'
		end
		
		it "has correct title" do
			should have_title 'Contract Settings | Costume Fittings'
			should have_selector 'h1', text: 'Contract Settings'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Contract Settings'
			should have_selector 'li.active', text: 'Costume Fittings'
		end
		
		it "displays correct data" do
			should have_content "15 minutes"
		end
		
		it "has links for Super Admin" do
			should have_link 'Edit Costume Fitting Settings'
		end
	end
end
