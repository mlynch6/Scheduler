require 'spec_helper'

describe "Biography Pages:" do
	subject { page }

	context "#show" do
		before do
			log_in
			@person = FactoryGirl.create(:person, account: current_account)
			click_link 'People'
			click_link 'Employees'
			click_link @person.name
			click_link 'Biography'
		end
		
		it "has correct title" do	
	  	should have_title "#{@person.full_name} | Biography"
		  should have_selector 'h1', text: @person.full_name
			should have_selector 'h1 small', text: 'Biography'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'People'
			should have_selector 'li.active', text: 'Employees'
			should have_selector 'li.active', text: 'Biography'
		end
		
		it "has biography info shown" do
			@employee = @person.profile
			
			should have_content @employee.biography
		end
		
		it "has links for Super Admin" do
			should have_link 'Edit Biography'
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
			click_link 'Biography'
			click_link 'Edit Biography'
		end
		
		it "has correct title" do	
	  	should have_title "#{@person.full_name} | Edit Biography"
			should have_selector 'h1', text: @person.full_name
			should have_selector 'h1 small', text: 'Edit Biography'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'People'
			should have_selector 'li.active', text: 'Employees'
			should have_selector 'li.active', text: 'Biography'
		end
		
		it "has correct fields on form" do
			should have_field 'Biography'
			should have_link 'Cancel', href: employee_biography_path(@employee)
		end
		
		it "with error shows error message" do
		pending "No fields currently cause error"
			fill_in "Biography", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	
		it "record with valid info saves employee" do
	  	fill_in "Biography", with: 'abc123'
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Biography'
			
			should have_content 'abc123'
		end
	end
end
