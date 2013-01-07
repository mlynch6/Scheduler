require 'spec_helper'

describe "Employee Pages:" do
	subject { page }
  
  context "#index" do
  	it "has correct title & table headers" do
			log_in
	  	visit employees_path
	  	
	  	should have_selector('title', text: 'Active Employees')
		  should have_selector('h1', text: 'Active Employees')
			
			should have_selector('th', text: "Name")
			should have_selector('th', text: "Email")
			should have_selector('th', text: "Phone")
		end
		
		it "without records" do
			log_in
			current_user.employee.inactivate
	  	visit employees_path
	  	
	    should have_content("No records found")
	    should have_selector('div.alert', text: "No records found")
			should_not have_selector('td')
			should_not have_selector('div.pagination')
		end
	  
		it "lists records" do
			log_in
			4.times { FactoryGirl.create(:employee, account: current_account) }
			visit employees_path(per_page: 3)
	
			should have_selector('div.pagination')
			Employee.active.paginate(page: 1, per_page: 3).each do |employee|
				should have_selector('td', text: employee.name)
				should have_link('Edit', href: edit_employee_path(employee))
				should have_link('Delete', href: employee_path(employee))
	    end
		end
		
		it "doesn't have links for Employee" do
			log_in_employee
			FactoryGirl.create(:employee, account: current_account)
			visit employees_path
	
			should_not have_link('New')
			should_not have_link('Edit')
			should_not have_link('Inactivate')
			should_not have_link('Delete')
		end
		
		it "has links for Administrator" do
			log_in_admin
			FactoryGirl.create(:employee, account: current_account)
			visit employees_path
	
			should have_link('New')
			should have_link('Edit')
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
			should have_selector('title', text: 'Active Employees')
				
			click_link 'Active'
			should_not have_content(employee.name)
				
			click_link 'Inactive'
			should have_content(employee.name)
		end
	end
	
	context "#inactive" do
		it "has correct title & table headers" do
			log_in
	  	visit employees_path
	  	click_link 'Inactive'
	  	
	  	should have_selector('title', text: 'Inactive Employees')
		  should have_selector('h1', text: 'Inactive Employees')
			
			should have_selector('th', text: "Name")
			should have_selector('th', text: "Email")
			should have_selector('th', text: "Phone")
		end
			
		it "without records" do
			log_in
			current_account.employees.inactive.delete_all
	  	visit employees_path
	  	click_link 'Inactive'
	  	
	    should have_selector('div.alert', text: "No records found")
			should_not have_selector('td')
			should_not have_selector('div.pagination')
		end
		
		it "lists records" do
			log_in
			4.times { FactoryGirl.create(:employee_inactive, account: current_account) }
			visit inactive_employees_path(per_page: 3)
	
			should have_selector('div.pagination')
			Employee.inactive.paginate(page: 1, per_page: 3).each do |employee|
				should have_selector('td', text: employee.name)
				should have_link('Activate', href: activate_employee_path(employee))
	    end
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
			
			click_link 'Inactive'
			should_not have_content(employee.name)
			
			click_link 'Active'
			should have_content(employee.name)
		end
	end

	context "#new" do
		it "has correct title" do
			log_in
			visit employees_path
	  	click_link 'New'
	
			should have_selector('title', text: 'New Employee')
			should have_selector('h1', text: 'New Employee')
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				visit employees_path
		  	click_link 'New'
		  	click_button 'Create'
		
				should have_selector('div.alert-error')
			end
			
			it "doesn't create Employee" do
				log_in
				visit employees_path
		  	click_link 'New'
		
				expect { click_button 'Create' }.not_to change(Employee, :count)
			end
		end
	
		it "record with valid info" do
			log_in
			visit employees_path
	  	click_link 'New'
	  	new_last_name = Faker::Name.last_name
	  	new_first_name = Faker::Name.first_name
	  	job_title = Faker::Name.title
	  	email = Faker::Internet.free_email("#{new_first_name} #{new_last_name}")
	  	fill_in "First Name", with: new_first_name
			fill_in "Last Name", with: new_last_name
			fill_in "Job Title", with: job_title
			fill_in "Phone", with: '111-222-3333'
			fill_in "Email", with: email
			click_button 'Create'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Active Employees')
			should have_content("#{new_last_name}, #{new_first_name}")
			should have_content(job_title)
			should have_content('111-222-3333')
			should have_content(email)
		end
	end

	context "#edit" do
		it "has correct title" do
			log_in
			employee = FactoryGirl.create(:employee, account: current_account)
			visit edit_employee_path(employee)
	  	
	  	should have_selector('title', text: 'Update Employee')
			should have_selector('h1', text: 'Update Employee')
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
	
			should have_selector('div.alert-error')
		end
	
		it "with bad record in URL shows 'Record Not Found' error" do
			pending
			log_in
			visit edit_employee_path(0)
	
			should have_content('Record Not Found')
		end
		
		it "record with wrong account shows 'Record Not Found' error" do
			pending
			log_in
			employee_wrong_account = FactoryGirl.create(:employee)
			visit edit_employee_path(employee_wrong_account)
	
			should have_content('Record Not Found')
		end
	
		it "record with valid info saves employee" do
			log_in
			employee = FactoryGirl.create(:employee, account: current_account)
			visit edit_employee_path(employee)
	  	new_last_name = Faker::Name.last_name
	  	new_first_name = Faker::Name.first_name
	  	job_title = Faker::Name.title
	  	email = Faker::Internet.free_email("#{new_first_name} #{new_last_name}")
	  	fill_in "First Name", with: new_first_name
			fill_in "Last Name", with: new_last_name
			fill_in "Job Title", with: job_title
			fill_in "Phone", with: '111-222-3333'
			fill_in "Email", with: email
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Active Employees')
			should have_content("#{new_last_name}, #{new_first_name}")
			should have_content(job_title)
			should have_content('111-222-3333')
			should have_content(email)
		end
	end
	
	it "#destroy deletes the record" do
		log_in
		employee = FactoryGirl.create(:employee, account: current_account, last_name: 'Delete Test')
		visit employees_path
		click_link "delete_#{employee.id}"
		
		should have_selector('div.alert-success')
		should have_selector('title', text: 'Active Employees')
		
		click_link 'Active'
		should_not have_content(employee.name)
		
		click_link 'Inactive'
		should_not have_content(employee.name)
	end
end
