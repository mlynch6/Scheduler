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
			should have_selector 'th', text: 'Status'
		end
		
		it "has correct Active/Inactive/All filter highlighting" do
			select "Inactive", from: 'status'
			click_button 'Search'
			should have_selector 'h1 small', text: 'Inactive'
			
			select "Active", from: 'status'
			click_button 'Search'
			should have_selector 'h1 small', text: 'Active'
			
			select "All", from: 'status'
			click_button 'Search'
			should have_selector 'h1 small', text: 'All'
			
			visit employees_path(status: "invalid")
			should have_selector 'h1 small', text: 'All'
		end
		
		it "without records" do
			person = current_user.person
			person.inactivate
	  	visit employees_path
	  	
	    should have_selector 'p', text: 'To begin'
			should_not have_selector 'td'
			should_not have_selector 'div.pagination'
		end
	  
		it "lists records" do
			4.times do
				@person = FactoryGirl.create(:person, account: current_account)
				FactoryGirl.create(:phone_person, phoneable: @person)
			end
			visit employees_path(per_page: 3)
	
			should have_selector('div.pagination')
			
			Employee.active.paginate(page: 1, per_page: 3).each do |employee|
				should have_selector 'td', text: employee.name
				should have_selector 'td', text: employee.job_title
				should have_selector 'td', text: employee.email
				should have_selector 'td', text: employee.status
				
				employee.phones.each do |phone|
					should have_selector 'td', text: "H: #{phone.phone_num}"
				end
				
				should have_link employee.name, href: employee_path(employee)
				should have_link 'Inactivate', href: inactivate_employee_path(employee)
				should have_link 'Delete', href: employee_path(employee)
	    end
		end
		
		describe "can search" do
			before do
				4.times { FactoryGirl.create(:person, account: current_account) }
				4.times { FactoryGirl.create(:person, :inactive, account: current_account) }
				@rhino = FactoryGirl.create(:person, account: current_account, first_name: 'Maxwell', last_name: 'Rhinoceros')
				visit employees_path
			end
			
			it "for active records" do	
				select "Active", from: 'status'
				click_button 'Search'
			
				Employee.active.each do |employee|
					should have_selector 'td', text: employee.name
					should have_selector 'td', text: 'Active'
					should_not have_selector 'td', text: 'Inactive'
					
					should have_link 'Inactivate', href: inactivate_employee_path(employee)
		    end
			end
			
			it "for inactive records" do	
				select "Inactive", from: 'status'
				click_button 'Search'
			
				Employee.inactive.each do |employee|
					should have_selector 'td', text: employee.name
					should_not have_selector 'td', text: 'Active'
					should have_selector 'td', text: 'Inactive'
					
					should have_link 'Activate', href: activate_employee_path(employee)
		    end
			end
		
			it "for all records" do
				select "All", from: 'status'
				click_button 'Search'
			
				Employee.all.each do |employee|
					should have_selector 'td', text: employee.name
					should have_selector 'td', text: 'Active'
					should have_selector 'td', text: 'Inactive'
		    end
			end
			
			it "on First Name" do
				fill_in "fname", with: 'Max'
				click_button 'Search'
			
				should have_selector 'tr', count: 2
				should have_selector 'td', text: @rhino.name
			end
			
			it "on Last Name" do
				fill_in "lname", with: 'Rhino'
				click_button 'Search'
			
				should have_selector 'tr', count: 2
				should have_selector 'td', text: @rhino.name
			end
		end
		
		it "has links for Super Admin" do
			@person = FactoryGirl.create(:person, account: current_account)
			visit employees_path
	
			should have_link @person.name
			should have_link 'Inactivate'
			should have_link 'Delete'
			
			should have_link 'Add Employee'
		end
	end
	
	context "#inactivate" do
		before do
			log_in
			@person = FactoryGirl.create(:person, account: current_account)
			@employee = @person.profile
			visit employees_path
			click_link "inactivate_#{@employee.id}"
		end
		
		it "changes employee status to inactive" do		
			should have_selector 'div.alert-success'
			should have_title 'Employees'
				
			select "Active", from: 'status'
			click_button 'Search'
			should_not have_content @person.name
				
			select "Inactive", from: 'status'
			click_button 'Search'
			should have_content @person.name
		end
	end
	
	context "#activate" do
		before do
			log_in
			@person = FactoryGirl.create(:person, account: current_account)
			@employee = @person.profile
			@person.inactivate
			visit employees_path(status: 'inactive')
			click_link "activate_#{@employee.id}"
		end
		
		it "changes employee status to active" do
			should have_selector 'div.alert-success'
			should have_title 'Employees'
			
			select "Active", from: 'status'
			click_button 'Search'
			should have_content @person.name
			
			select "Inactive", from: 'status'
			click_button 'Search'
			should_not have_content @person.name
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
			should have_field 'Middle Name'
	    should have_field 'Last Name'
			should have_field 'Suffix'
			should have_field 'Status'
	    should have_field 'Job Title'
			should have_field 'Gender'
			should have_field 'Birth Date'
	    should have_field 'Email'
			should have_field 'Biography'
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
			
			it "doesn't create Person" do
				expect { click_button 'Create' }.not_to change(Person, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Employee" do
		  	new_last_name = Faker::Name.last_name
		  	new_first_name = Faker::Name.first_name
		  	email = Faker::Internet.free_email("#{new_first_name} #{new_last_name}")
				
		  	fill_in "First Name", with: new_first_name
				fill_in "Last Name", with: new_last_name
				fill_in "Job Title", with: "Instructor"
				fill_in "Email", with: email
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Employees'
				should have_content "#{new_last_name}, #{new_first_name}"
				should have_content "Instructor"
				should have_content email
			end
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
			click_link 'Edit'
		end
		
		it "has correct title" do	
	  	should have_title 'Edit Employee'
			should have_selector 'h1', text: @person.full_name
			should have_selector 'h1 small', text: 'Edit'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'People'
			should have_selector 'li.active', text: 'Employees'
			should have_selector 'li.active', text: 'Overview'
		end
		
		it "has correct fields on form" do
			should have_field 'First Name'
			should have_field 'Middle Name'
	    should have_field 'Last Name'
			should have_field 'Suffix'
			should have_field 'Status'
	    should have_field 'Job Title'
			should have_field 'Gender'
			should have_field 'Birth Date'
	    should have_field 'Email'
			should have_field 'Biography'
			should have_link 'Cancel', href: employee_path(@employee)
		end
		
		it "with error shows error message" do
			fill_in "Last Name", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	
		it "record with valid info saves employee" do
	  	new_last_name = Faker::Name.last_name
	  	new_first_name = Faker::Name.first_name
	  	email = Faker::Internet.free_email("#{new_first_name} #{new_last_name}")
			
	  	fill_in "First Name", with: new_first_name
			fill_in "Middle Name", with: ""
			fill_in "Last Name", with: new_last_name
			fill_in "Suffix", with: ""
			fill_in "Job Title", with:  ""
			fill_in "Email", with: email
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title "#{new_first_name} #{new_last_name}"
			should have_content email
		end
		
		it "has links for Super Admin" do
			should have_link 'Delete'
		end
	end
	
	context "#show" do
		before do
			log_in
			@person = FactoryGirl.create(:person, :agma, account: current_account)
			click_link 'People'
			click_link 'Employees'
			click_link @person.name
		end
		
		it "has correct title" do	
	  	should have_title @person.full_name
		  should have_selector 'h1', text: @person.full_name
			should have_selector 'h1 small', text: @person.status
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'People'
			should have_selector 'li.active', text: 'Employees'
			should have_selector 'li.active', text: 'Overview'
		end
		
		it "has employee info shown" do
			@employee = @person.profile
			
			should have_content @person.full_name
			should have_content @employee.job_title
			should have_content @person.gender
			should have_content @person.birth_date
			should have_content @person.age
		  should have_content @person.email
			should have_content @person.status
		end
		
		describe "has user info shown" do
			context "when there is no user" do
				it "has 'Add User' link" do
					should have_link 'Add User', href: new_person_user_path(@person)
				end
				
				it "does not have 'Edit Permissions' link" do
					should_not have_link 'Edit Permissions'
				end
			end
			
			context "when there is a user" do
				it "has username shown" do
					@user = FactoryGirl.create(:user, account: current_account, person: @person)
					visit employee_path(@person.profile)
				
					should have_content @user.username
					should_not have_link 'Add User'
				end
			
				context "has Permission shown" do
					it "when user is a Super Administrator" do
						@user = FactoryGirl.create(:user, :superadmin, account: current_account, person: @person)
						visit employee_path(@person.profile)
				
						should have_content 'Super Administrator'
					end
				
					it "when user is a Basic User" do
						@user = FactoryGirl.create(:user, account: current_account, person: @person)
						visit employee_path(@person.profile)
				
						should have_content 'Basic User'
					end
				
					it "when user has multiple Permissions" do
						Rails.application.load_seed
						@user = FactoryGirl.create(:user, account: current_account, person: @person)
						role1 = Dropdown.of_type('UserRole').find_by_name('Manage Employees')
						FactoryGirl.create(:permission, account: current_account, user: @user, role: role1)
						role2 = Dropdown.of_type('UserRole').find_by_name('Manage Logins')
						FactoryGirl.create(:permission, account: current_account, user: @user, role: role2)
						visit employee_path(@person.profile)
				
						should have_content 'Basic User'
						should have_content 'Manage Employees'
						should have_content 'Manage Logins'
					end
				end
				
				it "does not have 'Add User' link" do
					@user = FactoryGirl.create(:user, account: current_account, person: @person)
					visit employee_path(@person.profile)
					
					should_not have_link 'Add User'
				end
				
				it "has 'Edit Permissions' link" do
					@user = FactoryGirl.create(:user, account: current_account, person: @person)
					visit employee_path(@person.profile)
					
					should have_link 'Edit Permissions', href: edit_permissions_path(@user)
				end
			end
		end
		
		it "has addresses shown" do
			@employee = @person.profile
			should have_selector 'h3', text: 'Addresses'
			@person.addresses.each do |address|
				should have_content "#{address.addr_type} Address"
				should have_content address.addr
				should have_content address.addr2 if address.addr2.present?
				should have_content address.city
				should have_content address.state
				should have_content address.zipcode
				
				should have_link 'Edit', href: edit_employee_address_path(@employee, address)
				should have_link 'Delete', href: employee_address_path(@employee, address)
			end
		end
		
		it "has phone numbers shown" do
			@employee = @person.profile
			should have_selector 'h3', text: 'Phone Numbers'
			@person.phones.each do |phone|
				should have_content "#{phone.phone_type}:"
				should have_content phone.phone_num
				
				should have_link 'Edit', href: edit_employee_phone_path(@employee, phone)
				should have_link 'Delete', href: employee_phone_path(@employee, phone)
			end
		end
		
		it "has links for Super Admin" do
			should have_link 'Edit'
			
			should have_link 'Add Address'
			should have_link 'Add Phone Number'
			should have_link 'Add User'
		end
	end
	
	context "#destroy" do
		before do
			log_in
			@person = FactoryGirl.create(:person, account: current_account)
			@employee = @person.profile
			click_link "People"
			click_link "Employees"
			click_link "delete_#{@employee.id}"
		end
		
		it "deletes the record" do
			should have_selector 'div.alert-success'
			should have_title 'Employees'
			
			select "All", from: 'status'
			click_button 'Search'
			should_not have_content @person.name
		end
	end
end
