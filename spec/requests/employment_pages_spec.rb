require 'spec_helper'

describe "Employment Pages:" do
	subject { page }

	context "#show" do
		before do
			log_in
			@person = FactoryGirl.create(:person, account: current_account)
			click_link 'People'
			click_link 'Employees'
			click_link @person.name
			click_link 'Employment'
		end
		
		it "has correct title" do	
	  	should have_title "#{@person.full_name} | Employment"
		  should have_selector 'h1', text: @person.full_name
			should have_selector 'h1 small', text: 'Employment'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'People'
			should have_selector 'li.active', text: 'Employees'
			should have_selector 'li.active', text: 'Employment'
		end
		
		it "has employment info shown" do
			@employee = @person.profile
			
			should have_content @employee.employee_num
			should have_content @employee.employment_start_date
			should have_content @employee.employment_end_date
		end
		
		it "has AGMA Artist shown" do
			@person = FactoryGirl.create(:person, :agma, account: current_account)
			visit employee_employment_path(@person.profile)
			
			should have_content 'AGMA Artist'
		end
		
		it "has Musician shown" do
			@person = FactoryGirl.create(:person, :musician, account: current_account)
			visit employee_employment_path(@person.profile)
			
			should have_content 'Musician'
		end
		
		it "has Instructor shown" do
			@person = FactoryGirl.create(:person, :instructor, account: current_account)
			visit employee_employment_path(@person.profile)
			
			should have_content 'Instructor'
		end
		
		it "has links for Super Admin" do
			should have_link 'Edit Employment'
		end
	end

	context "#edit" do
		before do
			log_in
			@person = FactoryGirl.create(:person, account: current_account)
			@employee = @person.profile
			click_link 'People'
			click_link 'Employees'
			click_link @person.name
			click_link 'Employment'
			click_link 'Edit Employment'
		end
		
		it "has correct title" do	
	  	should have_title "#{@person.full_name} | Edit Employment"
			should have_selector 'h1', text: @person.full_name
			should have_selector 'h1 small', text: 'Edit Employment'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'People'
			should have_selector 'li.active', text: 'Employees'
			should have_selector 'li.active', text: 'Employment'
		end
		
		it "has correct fields on form" do
			should have_field 'Employee #'
			should have_field 'Employment Start Date'
			should have_field 'Employment End Date'
			should have_field 'AGMA Artist'
			should have_field 'Musician'
			should have_field 'Instructor'
			should have_link 'Cancel', href: employee_employment_path(@employee)
		end
		
		it "with error shows error message" do
		pending "No fields currently cause error"
			fill_in "Employee #", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	
		it "record with valid info saves employee" do
	  	fill_in "Employee #", with: 'abc123'
			fill_in "Employment Start Date", with: '01/01/2010'
			fill_in "Employment End Date", with: '12/31/2010'
			check "AGMA Artist"
			check "Musician"
			check "Instructor"
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Employment'
			
			should have_content 'abc123'
			should have_content '01/01/2010'
			should have_content '12/31/2010'
			should have_content 'AGMA Artist'
			should have_content 'Musician'
			should have_content 'Instructor'
		end
	end
end
