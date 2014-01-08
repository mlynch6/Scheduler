require 'spec_helper'

describe "User Pages:" do
	subject { page }
  
  context "#index" do
  	it "has correct title" do
  		log_in
  		click_link "People"
	  	click_link "Users"
	  	
	  	should have_selector('title', text: 'Users')
		  should have_selector('h1', text: 'Users')
		end
		
		it "has correct Navigation" do
			log_in
	  	visit users_path
	  	
			should have_selector('li.active', text: 'People')
			should have_selector('li.active', text: 'Users')
		end
	  
		it "lists records" do
			log_in
			4.times {
				employee = FactoryGirl.create(:employee, account: current_account)
				FactoryGirl.create(:user, account: current_account, employee: employee)
				}
			visit users_path(per_page: 3)
	
			should have_selector('th', text: "Employee")
		  should have_selector('th', text: "Username")
			should have_selector('div.pagination')
			
			User.paginate(page: 1, per_page: 3).each do |user|
				should have_selector('td', text: user.employee.name)
				should have_selector('td', text: user.username)
				should have_link('Edit', href: edit_user_path(user))
				should have_link('Delete', href: user_path(user))
	    end
		end
		
		it "has links for Super Admin" do
			log_in
			employee = FactoryGirl.create(:employee, account: current_account)
			FactoryGirl.create(:user, account: current_account, employee: employee)
			visit users_path
	
			should have_link('Add User')
			should have_link('Edit')
			should have_link('Delete')
		end
		
		it "doesn't have links for Employee" do
			log_in_employee
			employee = FactoryGirl.create(:employee, account: current_account)
			FactoryGirl.create(:user, account: current_account, employee: employee)
			visit users_path
	
			should_not have_link('Add User')
			should_not have_link('Edit')
			should_not have_link('Delete')
		end
		
		it "has links for Administrator" do
			log_in_admin
			employee = FactoryGirl.create(:employee, account: current_account)
			FactoryGirl.create(:user, account: current_account, employee: employee)
			visit users_path
	
			should have_link('Add User')
			should have_link('Edit')
			should_not have_link('Delete')
		end
  end
  
  context "#new" do
  	it "has correct title" do
			log_in
			click_link "People"
	  	click_link "Users"
	  	click_link "Add User"
	
			should have_selector('title', text: 'Add User')
			should have_selector('h1', text: 'Add User')
		end
		
		it "has correct Navigation" do
			log_in
	  	visit new_user_path
	  	
			should have_selector('li.active', text: 'People')
			should have_selector('li.active', text: 'Users')
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				visit new_user_path
				click_button 'Create'
		
				should have_selector('div.alert-danger')
			end
			
			it "doesn't create User" do
				log_in
				visit new_user_path
		
				expect { click_button 'Create' }.not_to change(User, :count)
			end
		end
	
		context "with valid info" do
			it "creates new User" do
				log_in
				emp = FactoryGirl.create(:employee, account: current_account)
				visit new_user_path
		  	
		  	new_username = "New_Username"
		  	select emp.full_name, from: "Employee"
				fill_in "Username", with: new_username
				fill_in "Password", with: "password"
				fill_in "Confirm Password", with: "password"
				click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Users')
				should have_content(emp.name)
				should have_content(new_username.downcase)
			end
		end
  end
  
  context "#edit" do
  	it "has correct title" do
			log_in
			click_link "People"
	  	click_link "Users"
	  	click_link "Edit"
	
			should have_selector('title', text: 'Edit User')
			should have_selector('h1', text: 'Edit User')
			
			should have_content(current_user.username)
			should have_content(current_user.employee.full_name)
		end
		
		it "has correct Navigation" do
			log_in
	  	employee = FactoryGirl.create(:employee, account: current_account)
			user = FactoryGirl.create(:user, account: current_account, employee: employee)
	  	visit edit_user_path(user)
	  	
			should have_selector('li.active', text: 'People')
			should have_selector('li.active', text: 'Users')
		end
		
	  it "record with error" do
	  	log_in
	  	employee = FactoryGirl.create(:employee, account: current_account)
			user = FactoryGirl.create(:user, account: current_account, employee: employee)
	  	visit edit_user_path(user)
	  	
	  	fill_in "Password", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-danger')
		end
	 
		it "record with valid info saves user" do
			log_in
			employee = FactoryGirl.create(:employee, account: current_account)
			user = FactoryGirl.create(:user, account: current_account, employee: employee)
	  	visit edit_user_path(user)
	  	
			fill_in "Password", with: 'Updated'
			fill_in "Confirm Password", with: 'Updated'
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Users')
		end
  end
  
  context "#destroy" do
		it "deletes the record" do
	  	log_in
			employee = FactoryGirl.create(:employee, account: current_account)
			user = FactoryGirl.create(:user, account: current_account, employee: employee)
			visit users_path
			click_link "delete_#{user.id}"
			
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Users')
			
			should_not have_content(user.username)
		end
	end
end