require 'spec_helper'

describe "Employee Pages:" do
	subject { page }
  
  context "#index" do
		before do
			log_in
			click_link 'People'
	  	click_link 'Employees'
		end
		
  	it "has correct title & table headers" do
	  	should have_title 'Employees'
		  should have_selector 'h1', text: 'Employees'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'People'
			should have_selector 'li.active', text: 'Employees'
		end
		
		it "has correct table headers" do
			should have_selector 'th', text: 'Name'
			should have_selector 'th', text: 'Phone'
			should have_selector 'th', text: 'Email'
		end
		
		it "without records" do
			current_user.employee.inactivate
	  	visit employees_path
	  	
	    should have_selector 'p', text: 'To begin'
			should_not have_selector 'td'
			should_not have_selector 'div.pagination'
		end
	  
		it "lists records" do
			4.times do
				emp = FactoryGirl.create(:employee_complete, account: current_account)
				FactoryGirl.create(:phone_employee, phoneable: emp)
			end
			visit employees_path(per_page: 3)
	
			should have_selector('div.pagination')
			
			Employee.active.paginate(page: 1, per_page: 3).each do |employee|
				should have_selector 'td', text: employee.name
				should have_selector 'td', text: employee.email
				
				employee.phones.each do |phone|
					should have_selector 'td', text: "H: #{phone.phone_num}"
				end
				
				should have_link employee.name, href: employee_path(employee)
				should have_link 'Inactivate', href: inactivate_employee_path(employee)
				should have_link 'Delete', href: employee_path(employee)
	    end
		end
		
		it "has links for Super Admin" do
			employee = FactoryGirl.create(:employee, account: current_account)
			visit employees_path
	
			should have_link employee.name
			should have_link 'Inactivate'
			should have_link 'Delete'
			
			should have_link 'Add Employee'
		end
	end
	
	context "#inactivate" do
		before do
			log_in
			@employee = FactoryGirl.create(:employee, account: current_account, last_name: 'Inactivate Test')
			visit employees_path
			click_link "inactivate_#{@employee.id}"
		end
		
		it "changes employee status to inactive" do		
			should have_selector 'div.alert-success'
			should have_title 'Employees'
				
			click_link 'Employees'
			should_not have_content @employee.name
				
			click_link 'Inactive Employees'
			should have_content @employee.name
		end
	end
	
	context "#inactive" do
		before do
			log_in
			@employee = FactoryGirl.create(:employee_inactive, account: current_account)
			click_link 'People'
	  	click_link 'Inactive Employees'
		end
		
		it "has correct title" do	
	  	should have_title 'Inactive Employees'
		  should have_selector 'h1', text: 'Employees'
			should have_selector 'h1 small', text: 'Inactive'
		end
		
		it "has correct Navigation" do
			should have_selector('li.active', text: 'People')
			should have_selector('li.active', text: 'Inactive Employees')
		end
		
		it "has correct table headers" do
			should have_selector 'th', text: 'Name'
			should have_selector 'th', text: 'Phone'
			should have_selector 'th', text: 'Email'
		end
			
		it "without records" do
			@employee.activate
	  	click_link 'Inactive Employees'
			
	    should have_selector 'p', text: 'No employees are inactive'
			should_not have_selector 'td'
			should_not have_selector 'div.pagination'
		end
		
		it "lists records" do
			4.times do
				emp = FactoryGirl.create(:employee_complete, account: current_account, active: false)
				FactoryGirl.create(:phone_employee, phoneable: emp)
			end
			visit inactive_employees_path(per_page: 3)
	
			should have_selector 'div.pagination'
			
			Employee.inactive.paginate(page: 1, per_page: 3).each do |employee|
				should have_selector 'td', text: employee.name
				should have_selector 'td', text: employee.name
				should have_selector 'td', text: employee.name
				
				employee.phones.each do |phone|
					should have_selector 'td', text: "H: #{phone.phone_num}"
				end
				
				should have_link employee.name, href: employee_path(employee)
				should have_link 'Activate', href: activate_employee_path(employee)
				should have_link 'Delete', href: employee_path(employee)
	    end
		end
		
		it "has links for Super Admin" do
			should have_link @employee.name
			should have_link 'Activate'
			should have_link 'Delete'
			
			should have_link 'Add Employee'
		end
	end
	
	context "#activate" do
		before do
			log_in
			@employee = FactoryGirl.create(:employee_inactive, account: current_account, last_name: 'Activate Test')
			visit inactive_employees_path
			click_link "activate_#{@employee.id}"
		end
		
		it "changes employee status to active" do
			should have_selector 'div.alert-success'
			should have_title 'Inactive Employees'
			
			click_link 'Employees'
			should have_content @employee.name
			
			click_link 'Inactive Employees'
			should_not have_content @employee.name
		end
	end

	context "#new" do
		before do
			log_in
			click_link 'People'
	  	click_link 'Employees'
	  	click_link 'Add Employee'
		end
		
		it "has correct title" do
			should have_title 'Add Employee'
			should have_selector 'h1', text: 'Employees'
			should have_selector 'h1 small', text: 'Add'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'People'
			should have_selector 'li.active', text: 'Employees'
		end
		
		it "has correct fields on form" do
			should have_field 'First Name'
	    should have_field 'Last Name'
	    should have_select 'Role'
	    should have_field 'Email'
			should have_link 'Cancel', href: employees_path
		end
		
		context "with error" do
			it "shows error message" do
		  	click_button 'Create'
		
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Employee" do
				expect { click_button 'Create' }.not_to change(Employee, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Employee" do
		  	new_last_name = Faker::Name.last_name
		  	new_first_name = Faker::Name.first_name
		  	email = Faker::Internet.free_email("#{new_first_name} #{new_last_name}")
				
		  	fill_in "First Name", with: new_first_name
				fill_in "Last Name", with: new_last_name
				select "Instructor", from: "Role"
				fill_in "Email", with: email
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Employees'
				should have_content "#{new_last_name}, #{new_first_name}"
				should have_content email
			end
		end
		
		it "has links for Super Admin" do
			should have_link 'Add Employee'
		end
	end

	context "#edit" do
		before do
			log_in
			@employee = FactoryGirl.create(:employee, account: current_account)
			click_link 'People'
			click_link 'Employees'
			click_link @employee.name
			click_link @employee.full_name
		end
		
		it "has correct title" do	
	  	should have_title 'Edit Employee'
			should have_selector 'h1', text: 'Employees'
			should have_selector 'h1 small', text: 'Edit'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'People'
			should have_selector 'li.active', text: 'Employees'
		end
		
		it "has correct fields on form" do
			should have_field 'First Name'
	    should have_field 'Last Name'
	    should have_select 'Role'
	    should have_field 'Email'
			should have_field 'Status'
			should have_link 'Cancel', href: employee_path(@employee)
		end
		
		it "with error shows error message" do
			invalid_email = "abc"

			fill_in "Email", with: invalid_email
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	
		it "record with valid info saves employee" do
	  	new_last_name = Faker::Name.last_name
	  	new_first_name = Faker::Name.first_name
	  	email = Faker::Internet.free_email("#{new_first_name} #{new_last_name}")
			
	  	fill_in "First Name", with: new_first_name
			fill_in "Last Name", with: new_last_name
			select "Instructor", from: "Role"
			fill_in "Email", with: email
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Employees'
			should have_content "#{new_last_name}, #{new_first_name}"
			should have_content email
		end
		
		it "has links for Super Admin" do
			should have_link 'Add Employee'
			should have_link 'Delete Employee'
			should have_link 'Add Address'
			should have_link 'Add Phone Number'
		end
	end
	
	context "#show" do
		before do
			log_in
			@employee = FactoryGirl.create(:employee, account: current_account)
			click_link 'People'
			click_link 'Employees'
			click_link @employee.name
		end
		
		it "has correct title" do	
	  	should have_title @employee.full_name
		  should have_selector 'h1', text: @employee.full_name
			should have_selector 'h1 small', text: @employee.status
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'People'
			should have_selector 'li.active', text: 'Employees'
		end
		
		it "has employee info shown" do
			should have_content @employee.full_name
			should have_content @employee.status
		  should have_content @employee.role
		  should have_content @employee.email
		end
		
		it "has addresses shown" do
			should have_selector 'h3', text: 'Addresses'
			@employee.addresses.each do |address|
				should have_content "#{address.addr_type} Address"
				should have_content address.addr
				should have_content address.addr2 if address.addr2.present?
				should have_content address.city
				should have_content address.state
				should have_content address.zipcode
				
				should have_link 'Edit', href: edit_employee_address_path(employee, address)
				should have_link 'Delete', href: employee_address_path(employee, address)
			end
		end
		
		it "has phone numbers shown" do
			should have_selector 'h3', text: 'Phone Numbers'
			@employee.phones.each do |phone|
				should have_content "#{phone.phone_type}:"
				should have_content phone.phone_num
				
				should have_link 'Edit', href: edit_employee_phone_path(employee, phone)
				should have_link 'Delete', href: employee_phone_path(employee, phone)
			end
		end
		
		it "has links for Super Admin" do
			should have_link @employee.full_name
			
			should have_link 'Overview'
			
			should have_link 'Add Employee'
			should have_link 'Delete Employee'
			should have_link 'Add Address'
			should have_link 'Add Phone Number'
		end
	end
	
	context "#destroy" do
		before do
			log_in
			@employee = FactoryGirl.create(:employee, account: current_account)
			click_link "People"
			click_link "Employees"
			click_link "delete_#{@employee.id}"
		end
		
		it "deletes the record" do
			should have_selector 'div.alert-success'
			should have_title 'Employees'
			
			click_link 'Employees'
			should_not have_content @employee.name
			
			click_link 'Inactive Employees'
			should_not have_content @employee.name
		end
	end
end
