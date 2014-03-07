require 'spec_helper'

describe "Phone Pages:" do
	subject { page }
	
	context "#new" do
		context "for Account" do
			it "has correct title" do
				log_in
				click_link "Setup"
				click_link "Company Information"
		  	click_link 'Add Phone Number'
		
				has_title?('Add Phone Number').should be_true
				should have_selector('h1', text: 'Add Phone Number')
			end
			
			it "has correct Navigation" do
				log_in
				visit new_account_phone_path(current_account)
		
				should have_selector('li.active', text: 'Setup')
				should have_selector('li.active', text: 'Company Information')
			end
			
			it "has correct fields on form" do
				log_in
				visit new_account_phone_path(current_account)
				
				has_select?('Phone Type').should be_true
		    has_field?('Phone #').should be_true
			end
			
			context "with error" do
				it "shows error message" do
					log_in
					visit new_account_phone_path(current_account)
			  	click_button 'Create'
			
					should have_selector('div.alert-danger')
				end
				
				it "doesn't create Phone Number" do
					log_in
					visit new_account_phone_path(current_account)
			
					expect { click_button 'Create' }.not_to change(Phone, :count)
				end
			end
		
			context "with valid info" do
				it "creates new Phone Number" do
					log_in
					visit new_account_phone_path(current_account)
					
			  	new_phone = '888-777-7666'
			  	
			  	select "Cell", from: "Phone Type"
			  	fill_in "Phone #", with: new_phone
					click_button 'Create'
			
					should have_selector('div.alert-success')
					has_title?('Company Information').should be_true
					
					should have_content("Cell:")
					should have_content(new_phone)
				end
			end
		end
		
		context "for Employee" do
			it "has correct title" do
				log_in
				click_link "People"
				click_link "Employees"
		  	click_link "View"
		  	click_link 'Add Phone Number'
		
				has_title?('Add Phone Number').should be_true
				should have_selector('h1', text: 'Add Phone Number')
			end
			
			it "has correct Navigation" do
				log_in
				employee = FactoryGirl.create(:employee, account: current_account)
				visit new_employee_phone_path(employee)
		
				should have_selector('li.active', text: 'People')
				should have_selector('li.active', text: 'Employees')
			end
			
			it "has correct fields on form" do
				log_in
				employee = FactoryGirl.create(:employee, account: current_account)
				visit new_employee_phone_path(employee)
				
				has_select?('Phone Type').should be_true
		    has_field?('Phone #').should be_true
			end
			
			context "with error" do
				it "shows error message" do
					log_in
					employee = FactoryGirl.create(:employee, account: current_account)
					visit new_employee_phone_path(employee)
			  	click_button 'Create'
			
					should have_selector('div.alert-danger')
				end
				
				it "doesn't create Phone Number" do
					log_in
					employee = FactoryGirl.create(:employee, account: current_account)
					visit new_employee_phone_path(employee)
			
					expect { click_button 'Create' }.not_to change(Phone, :count)
				end
			end
		
			context "with valid info" do
				it "creates new Phone Number" do
					log_in
					employee = FactoryGirl.create(:employee, account: current_account)
					visit new_employee_phone_path(employee)
					
			  	new_phone = '887-666-4444'
			  	
			  	select "Cell", from: "Phone Type"
			  	fill_in "Phone #", with: new_phone
					click_button 'Create'
			
					should have_selector('div.alert-success')
					has_title?('Employee').should be_true
					
					should have_content("Cell:")
					should have_content(new_phone)
				end
			end
		end
	end

	context "#edit" do
		context "for Account" do
			it "has correct title" do
				log_in
				phone = FactoryGirl.create(:phone, phoneable: current_account)
				
				click_link "Setup"
				click_link "Company Information"
		  	click_link "edit_phone_#{phone.id}"
		  	
		  	has_title?('Edit Phone Number').should be_true
				should have_selector('h1', text: 'Edit Phone Number')
			end
			
			it "has correct Navigation" do
				log_in
				phone = FactoryGirl.create(:phone, phoneable: current_account)
				visit edit_account_phone_path(current_account, phone)
		
				should have_selector('li.active', text: 'Setup')
				should have_selector('li.active', text: 'Company Information')
			end
			
			it "has correct fields on form" do
				log_in
				phone = FactoryGirl.create(:phone, phoneable: current_account)
				visit edit_account_phone_path(current_account, phone)
				
				has_select?('Phone Type').should be_true
		    has_field?('Phone #').should be_true
			end
			
			it "with error shows error message" do
				log_in
				phone = FactoryGirl.create(:phone, phoneable: current_account)
				visit edit_account_phone_path(current_account, phone)
				
				fill_in "Phone #", with: ""
		  	click_button 'Update'
		
				should have_selector('div.alert-danger')
			end
		
			it "record with valid info saves address" do
				log_in
				phone = FactoryGirl.create(:phone, phoneable: current_account)
				visit edit_account_phone_path(current_account, phone)
				
		  	new_phone = '543-863-5309'
		  	
		  	select "Work", from: "Phone Type"
		  	fill_in "Phone #", with: new_phone
				click_button 'Update'
		
				should have_selector('div.alert-success')
				has_title?('Company Information').should be_true
				
				should have_content("Work:")
				should have_content(new_phone)
			end
		end
		
		context "for Employee" do
			it "has correct title" do
				log_in
				employee = FactoryGirl.create(:employee, account: current_account)
				phone = FactoryGirl.create(:phone, phoneable: employee)
				
				click_link "People"
				click_link "Employees"
				click_link "show_#{employee.id}"
		  	click_link "edit_phone_#{phone.id}"
		  	
		  	has_title?('Edit Phone Number').should be_true
				should have_selector('h1', text: 'Edit Phone Number')
			end
			
			it "has correct Navigation" do
				log_in
				employee = FactoryGirl.create(:employee, account: current_account)
				phone = FactoryGirl.create(:phone, phoneable: employee)
				visit edit_employee_phone_path(employee, phone)
		
				should have_selector('li.active', text: 'People')
				should have_selector('li.active', text: 'Employees')
			end
			
			it "has correct fields on form" do
				log_in
				employee = FactoryGirl.create(:employee, account: current_account)
				phone = FactoryGirl.create(:phone, phoneable: employee)
				visit edit_employee_phone_path(employee, phone)
				
				has_select?('Phone Type').should be_true
		    has_field?('Phone #').should be_true
			end
			
			it "with error shows error message" do
				log_in
				employee = FactoryGirl.create(:employee, account: current_account)
				phone = FactoryGirl.create(:phone, phoneable: employee)
				visit edit_employee_phone_path(employee, phone)
				
				fill_in "Phone #", with: ""
		  	click_button 'Update'
		
				should have_selector('div.alert-danger')
			end
		
			it "record with valid info saves address" do
				log_in
				employee = FactoryGirl.create(:employee, account: current_account)
				phone = FactoryGirl.create(:phone, phoneable: employee)
				visit edit_employee_phone_path(employee, phone)
				
		  	new_phone = '543-863-5309'
		  	
		  	select "Work", from: "Phone Type"
		  	fill_in "Phone #", with: new_phone
				click_button 'Update'
		
				should have_selector('div.alert-success')
				has_title?('Employee').should be_true
				
				should have_content("Work:")
				should have_content(new_phone)
			end
		end
	end
	
	context "#destroy" do
		context "for Account" do
			it "deletes the phone record" do
				log_in
				phone = FactoryGirl.create(:phone, phoneable: current_account)
				visit account_path(current_account)
				click_link "delete_phone_#{phone.id}"
				
				should have_selector('div.alert-success')
				has_title?('Company Information').should be_true
				
				should_not have_content("#{phone.phone_type}:")
				should_not have_content(phone.phone_num)
			end
		end
		
		context "for Employee" do
			it "deletes the phone record" do
				log_in
				employee = FactoryGirl.create(:employee, account: current_account)
				phone = FactoryGirl.create(:phone_employee, phoneable: employee)
				visit employee_path(employee)
				click_link "delete_phone_#{phone.id}"
				
				should have_selector('div.alert-success')
				has_title?('Employee').should be_true
				
				should_not have_content("#{phone.phone_type}:")
				should_not have_content(phone.phone_num)
			end
		end
	end
end
