require 'spec_helper'

describe "Employee Pages:" do
	subject { page }
  
  context "#index" do
  	it "has correct title & table headers" do
			log_in
			click_link "People"
	  	click_link "Employees"
	  	
	  	should have_selector('title', text: 'Employees')
		  should have_selector('h1', text: 'Employees')
		end
		
		it "has correct Navigation" do
			log_in
	  	visit employees_path
	
			should have_selector('li.active', text: 'People')
			should have_selector('li.active', text: 'Employees')
		end
		
		it "without records" do
			log_in
			current_user.employee.inactivate
	  	visit employees_path
	  	
	    should have_selector('p', text: 'To begin')
			should_not have_selector('td')
			should_not have_selector('div.pagination')
		end
	  
		it "lists records" do
			log_in
			4.times { FactoryGirl.create(:employee, account: current_account) }
			visit employees_path(per_page: 3)
	
			should have_selector('th', text: "Name")
			should have_selector('th', text: "Role")
			should have_selector('div.pagination')
			
			Employee.active.paginate(page: 1, per_page: 3).each do |employee|
				should have_selector('td', text: employee.name)
				should have_link('Show', href: employee_path(employee))
				should have_link('Inactivate', href: inactivate_employee_path(employee))
				should have_link('Delete', href: employee_path(employee))
	    end
		end
		
		it "has links for Super Admin" do
			log_in
			FactoryGirl.create(:employee, account: current_account)
			visit employees_path
	
			should have_link('Add Employee')
			should have_link('View')
			should have_link('Inactivate')
			should have_link('Delete')
		end
		
		it "doesn't have links for Employee" do
			log_in_employee
			FactoryGirl.create(:employee, account: current_account)
			visit employees_path
	
			should_not have_link('Add Employee')
			should_not have_link('View')
			should_not have_link('Inactivate')
			should_not have_link('Delete')
		end
		
		it "has links for Administrator" do
			log_in_admin
			FactoryGirl.create(:employee, account: current_account)
			visit employees_path
	
			should have_link('Add Employee')
			should have_link('View')
			should have_link('Inactivate')
			should_not have_link('Delete')
		end
	end
	
	context "#inactivate" do
		it "changes employee status to inactive" do
			log_in
			employee = FactoryGirl.create(:employee, account: current_account, last_name: 'Inactivate Test')
			visit employees_path
			click_link "inactivate_#{employee.id}"
				
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Employees')
				
			click_link 'Employees'
			should_not have_content(employee.name)
				
			click_link 'Inactive Employees'
			should have_content(employee.name)
		end
	end
	
	context "#inactive" do
		it "has correct title" do
			log_in
			click_link "People"
	  	click_link "Inactive Employees"
	  	
	  	should have_selector('title', text: 'Inactive Employees')
		  should have_selector('h1', text: 'Inactive Employees')
		end
		
		it "has correct Navigation" do
			log_in
	  	visit inactive_employees_path
	
			should have_selector('li.active', text: 'People')
			should have_selector('li.active', text: 'Inactive Employees')
		end
			
		it "without records" do
			log_in
			current_account.employees.inactive.delete_all
	  	visit inactive_employees_path
	  	
	    should have_selector('p', text: 'No employees are inactive')
			should_not have_selector('td')
			should_not have_selector('div.pagination')
		end
		
		it "lists records" do
			log_in
			4.times { FactoryGirl.create(:employee_inactive, account: current_account) }
			visit inactive_employees_path(per_page: 3)
	
			should have_selector('th', text: "Name")
			should have_selector('th', text: "Role")
			should have_selector('div.pagination')
			
			Employee.inactive.paginate(page: 1, per_page: 3).each do |employee|
				should have_selector('td', text: employee.name)
				should have_link('Activate', href: activate_employee_path(employee))
				should have_link('Delete', href: employee_path(employee))
	    end
		end
		
		it "has links for Super Admin" do
			log_in
			FactoryGirl.create(:employee_inactive, account: current_account)
			visit inactive_employees_path
			
			should have_link('Activate')
			should have_link('Delete')
		end
		
		it "doesn't have links for Employee" do
			log_in_employee
			FactoryGirl.create(:employee_inactive, account: current_account)
			visit inactive_employees_path
			
			should_not have_link('Activate')
			should_not have_link('Delete')
		end
		
		it "has links for Administrator" do
			log_in_admin
			FactoryGirl.create(:employee_inactive, account: current_account)
			visit inactive_employees_path
			
			should have_link('Activate')
			should_not have_link('Delete')
		end
	end
	
	context "#activate" do
		it "changes employee status to active" do
			log_in
			employee = FactoryGirl.create(:employee_inactive, account: current_account, last_name: 'Activate Test')
			visit inactive_employees_path
			click_link "activate_#{employee.id}"
			
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Inactive Employees')
			
			click_link 'Employees'
			should have_content(employee.name)
			
			click_link 'Inactive Employees'
			should_not have_content(employee.name)
		end
	end

	context "#new" do
		it "has correct title" do
			log_in
			click_link "People"
	  	click_link "Employees"
	  	click_link 'Add Employee'
	
			should have_selector('title', text: 'Add Employee')
			should have_selector('h1', text: 'Add Employee')
		end
		
		it "has correct Navigation" do
			log_in
	  	visit new_employee_path
	
			should have_selector('li.active', text: 'People')
			should have_selector('li.active', text: 'Employees')
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				visit new_employee_path
		  	click_button 'Create'
		
				should have_selector('div.alert-danger')
			end
			
			it "doesn't create Employee" do
				log_in
				visit new_employee_path
		
				expect { click_button 'Create' }.not_to change(Employee, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Employee" do
				log_in
				visit new_employee_path
				
		  	new_last_name = Faker::Name.last_name
		  	new_first_name = Faker::Name.first_name
		  	email = Faker::Internet.free_email("#{new_first_name} #{new_last_name}")
		  	fill_in "First Name", with: new_first_name
				fill_in "Last Name", with: new_last_name
				select "Instructor", from: "Role"
				fill_in "Email", with: email
				click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Employees')
				should have_content("#{new_last_name}, #{new_first_name}")
				should have_content("Instructor")
			end
		end
	end

	context "#edit" do
		it "has correct title" do
			log_in
			employee = FactoryGirl.create(:employee, account: current_account)
			click_link "People"
			click_link "Employees"
			click_link "View"
			click_link "Edit"
	  	
	  	should have_selector('title', text: 'Edit Employee')
			should have_selector('h1', text: 'Edit Employee')
		end
		
		it "has correct Navigation" do
			log_in
	  	employee = FactoryGirl.create(:employee, account: current_account)
			visit edit_employee_path(employee)
	
			should have_selector('li.active', text: 'People')
			should have_selector('li.active', text: 'Employees')
		end
		
		it "has Username on page"
		it "allows reset of password"
		
		it "with error shows error message" do
			log_in
			employee = FactoryGirl.create(:employee, account: current_account)
			invalid_email = "abc"
			visit edit_employee_path(employee)
			fill_in "Email", with: invalid_email
	  	click_button 'Update'
	
			should have_selector('div.alert-danger')
		end
	
		it "record with valid info saves employee" do
			log_in
			employee = FactoryGirl.create(:employee, account: current_account)
			visit edit_employee_path(employee)
	  	new_last_name = Faker::Name.last_name
	  	new_first_name = Faker::Name.first_name
	  	email = Faker::Internet.free_email("#{new_first_name} #{new_last_name}")
	  	fill_in "First Name", with: new_first_name
			fill_in "Last Name", with: new_last_name
			select "Instructor", from: "Role"
			fill_in "Email", with: email
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Employees')
			should have_content("#{new_last_name}, #{new_first_name}")
			should have_content("Instructor")
		end
	end
	
	context "#show" do
		it "has correct title" do	
			log_in
			employee = FactoryGirl.create(:employee, account: current_account)
	  	visit employees_path
			click_link "show_#{employee.id}"
	  	
	  	should have_selector('title', text: 'Employee')
		  should have_selector('h1', text: employee.full_name)
		end
		
		it "has correct Navigation" do
			log_in
	  	employee = FactoryGirl.create(:employee, account: current_account)
	  	visit employee_path(employee)
	
			should have_selector('li.active', text: 'People')
			should have_selector('li.active', text: 'Employees')
		end
		
		it "has employee info shown" do
			log_in
			employee = FactoryGirl.create(:employee, account: current_account)
	  	visit employee_path(employee)
	  	
			should have_content("Active")
		  should have_content(employee.role)
		  should have_content(employee.email)
		end
		
		it "has addresses shown" do
			log_in
			employee = FactoryGirl.create(:employee_w_addresses, account: current_account)
			visit employee_path(employee)

			should have_selector('h3', text: 'Addresses')
			employee.addresses.each do |address|
				should have_content("#{address.addr_type} Address")
				should have_content(address.addr)
				should have_content(address.addr2) if address.addr2.present?
				should have_content(address.city)
				should have_content(address.state)
				should have_content(address.zipcode)
				
				should have_link('Edit', href: edit_employee_address_path(employee, address))
				should have_link('Delete', href: employee_address_path(employee, address))
			end
	    should have_link('Add Address')
		end
		
		it "has phone numbers shown" do
			log_in
			employee = FactoryGirl.create(:employee_w_phones, account: current_account)
			visit employee_path(employee)

			should have_selector('h3', text: 'Phone Numbers')
			employee.phones.each do |phone|
				should have_content("#{phone.phone_type}:")
				should have_content(phone.phone_num)
				
				should have_link('Edit', href: edit_employee_phone_path(employee, phone))
				should have_link('Delete', href: employee_phone_path(employee, phone))
			end
	    should have_link('Add Phone Number')
		end
		
		it "has links for Super Admin" do
			log_in
			employee = FactoryGirl.create(:employee, account: current_account)
	  	visit employee_path(employee)
	
			should have_link('Edit')
			should have_link('Add Address')
			should have_link('Add Phone Number')
		end
		
		it "doesn't have links for Employee" do
			log_in_employee
			employee = FactoryGirl.create(:employee, account: current_account)
	  	visit employee_path(employee)
	  	
			should_not have_link('Edit')
			should_not have_link('Add Address')
			should_not have_link('Add Phone Number')
		end
		
		it "has links for Administrator" do
			log_in_admin
			employee = FactoryGirl.create(:employee, account: current_account)
	  	visit employee_path(employee)
	
			should have_link('Edit')
			should have_link('Add Address')
			should have_link('Add Phone Number')
		end
	end
	
	context "#destroy" do
		it "deletes the record" do
			log_in
			employee = FactoryGirl.create(:employee, account: current_account, last_name: 'Delete Test')
			click_link "People"
			click_link "Employees"
			click_link "delete_#{employee.id}"
			
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Employees')
			
			click_link 'Employees'
			should_not have_content(employee.name)
			
			click_link 'Inactive Employees'
			should_not have_content(employee.name)
		end
	end
end
