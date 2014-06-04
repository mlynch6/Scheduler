require 'spec_helper'

describe "User Pages:" do
	subject { page }
  
  context "#index" do
		before do
  		log_in
			@employee = FactoryGirl.create(:employee, account: current_account)
			@user = FactoryGirl.create(:user, account: current_account, employee: @employee)
  		click_link 'People'
	  	click_link 'Users'
		end
		
  	it "has correct title" do
	  	should have_title 'Users'
		  should have_selector 'h1', text: 'Users'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'People'
			should have_selector 'li.active', text: 'Users'
		end
		
		it "has correct table headers" do
			should have_selector 'th', text: 'Employee'
			should have_selector 'th', text: 'Username'
		end
	  
		it "lists records" do
			4.times {
				employee = FactoryGirl.create(:employee, account: current_account)
				FactoryGirl.create(:user, account: current_account, employee: employee)
				}
			visit users_path(per_page: 3)
	
			should have_selector 'div.pagination'
			
			User.paginate(page: 1, per_page: 3).each do |user|
				should have_selector 'td', text: user.employee.name
				should have_selector 'td', text: user.username
				should have_link user.username, href: edit_user_path(user)
				should have_link 'Delete', href: user_path(user)
	    end
		end
		
		it "has links for Super Admin" do
			should have_link 'Add User'
			should have_link @user.username
			should have_link 'Delete'
		end
  end
  
  context "#new" do
		before do
			log_in
			@employee = FactoryGirl.create(:employee, account: current_account)
			click_link 'People'
	  	click_link 'Users'
	  	click_link 'Add User'
		end
		
  	it "has correct title" do
			should have_title 'Add User'
			should have_selector 'h1', text: 'Users'
			should have_selector 'h1 small', text: 'Add'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'People'
			should have_selector 'li.active', text: 'Users'
		end
		
		it "has correct fields on form" do
	  	should have_content 'Employee' 	#Using Chosen
			should have_field 'Username'
	    should have_field 'Password'
	    should have_field 'Confirm Password'
			should have_link 'Cancel', href: users_path
		end
		
		context "with error" do
			it "shows error message" do
				click_button 'Create'
		
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create User" do
				expect { click_button 'Create' }.not_to change(User, :count)
			end
		end
	
		context "with valid info" do
			it "creates new User" do
		  	new_username = "New_Username"
				
		  	select @employee.full_name, from: "Employee"
				fill_in "Username", with: new_username
				fill_in "Password", with: "password"
				fill_in "Confirm Password", with: "password"
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Users'
				should have_content @employee.name
				should have_content new_username.downcase
			end
		end
  end
  
  context "#edit" do
		before do
			log_in
			@employee = FactoryGirl.create(:employee, account: current_account)
			@user = FactoryGirl.create(:user, account: current_account, employee: @employee)
			click_link 'People'
	  	click_link 'Users'
	  	click_link @user.username
		end
		
  	it "has correct title" do
			should have_title 'Edit User'
			should have_selector 'h1', text: 'User'
			should have_selector 'h1 small', text: 'Edit'
			
			should have_content @user.username
			should have_content @user.employee.full_name
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'People'
			should have_selector 'li.active', text: 'Users'
		end
		
		it "has correct fields on form" do
	  	should have_field 'Password'
	    should have_field 'Confirm Password'
			should have_link 'Cancel', href: users_path
		end
		
	  it "record with error" do
	  	fill_in "Password", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "record with valid info saves user" do
			fill_in "Password", with: 'Updated'
			fill_in "Confirm Password", with: 'Updated'
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Users'
		end
  end
  
  context "#destroy" do
		before do
	  	log_in
			@employee = FactoryGirl.create(:employee, account: current_account)
			@user = FactoryGirl.create(:user, account: current_account, employee: @employee)
			click_link 'People'
	  	click_link 'Users'
			click_link "delete_#{@user.id}"
		end
		
		it "deletes the record" do
			should have_selector 'div.alert-success'
			should have_title 'Users'
			
			should_not have_content @user.username
		end
	end
end