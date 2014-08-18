require 'spec_helper'

describe "Dropdown Pages:" do
	subject { page }
  
  context "#index" do
		before do
  		log_in
  		click_link "Administration"
			click_link "Dropdowns"
		end
		
  	it "has correct title" do
			select "UserRole", from: 'type'
			click_button 'Search'
			
	  	should have_title 'Dropdowns'
			should have_title 'User Roles'
		  should have_selector 'h1', text: 'User Roles'
			should have_selector 'h1 small', text: 'All'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Administration'
			should have_selector 'li.active', text: 'Dropdowns'
		end
		
		it "has correct table headers" do
			should have_selector 'th', text: "Name"
			should have_selector 'th', text: "Description"
			should have_selector 'th', text: "Status"
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
			
			visit admin_dropdowns_path(status: "invalid")
			should have_selector 'h1 small', text: 'All'
		end
		
		it "without records" do
			should have_selector 'td', text: 'No records found'
		end
	  
		it "lists all records by default" do
			4.times { FactoryGirl.create(:dropdown, :user_role) }
			4.times { FactoryGirl.create(:dropdown, :user_role, :inactive) }
			visit admin_dropdowns_path(type: 'UserRole')
			
			should have_selector 'td', text: 'Active'
			should have_selector 'td', text: 'Inactive'
			Dropdown.of_type('UserRole').each do |dropdown|
				should have_selector 'td', text: dropdown.name
				should have_selector 'td', dropdown.comment
				
				should have_link dropdown.name, href: edit_admin_dropdown_path(dropdown)
				should have_link 'Delete', href: admin_dropdown_path(dropdown)
	    end
		end
		
		describe "can search" do
			before do
				4.times { FactoryGirl.create(:dropdown, :user_role) }
				4.times { FactoryGirl.create(:dropdown, :user_role, :inactive) }
				@rhino = FactoryGirl.create(:dropdown, :user_role, name: 'I am Rhino 7')
				visit admin_dropdowns_path
			end
			
			it "for inactive records" do
				select "UserRole", from: 'type'
				select "Inactive", from: 'status'
				click_button 'Search'
			
				should_not have_selector 'td', text: 'Active'
				should have_selector 'td', text: 'Inactive'
				Dropdown.of_type('UserRole').inactive.each do |role|
					should have_selector 'td', text: role.name
		    end
			end
		
			it "for active records" do
				select "UserRole", from: 'type'
				select "Active", from: 'status'
				click_button 'Search'
			
				should have_selector 'td', text: 'Active'
				should_not have_selector 'td', text: 'Inactive'
				Dropdown.of_type('UserRole').active.each do |role|
					should have_selector 'td', text: role.name
		    end
			end
			
			it "on Name" do
				select "UserRole", from: 'type'
				fill_in "query", with: 'Rhino'
				click_button 'Search'
			
				should have_selector 'tr', count: 2
				should have_selector 'td', text: @rhino.name
			end
		end
		
		it "has links for Super Admin" do
			role = FactoryGirl.create(:dropdown, :user_role)
			visit admin_dropdowns_path(type: 'UserRole')
	
			should have_link 'Add User Role', href: new_admin_dropdown_path(type: 'UserRole')
			should have_link role.name
			should have_link 'Delete'
		end
	end

	context "#new" do
		before do
			log_in
			click_link "Administration"
	  	click_link "Dropdowns"
			select "UserRole", from: 'type'
			click_button 'Search'
	  	click_link "Add User Role"
		end
		
		it "has correct title" do
			should have_title 'Add Dropdown | User Role'
			should have_selector 'h1', text: 'User Roles'
			should have_selector 'h1 small', text: 'Add'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Administration'
			should have_selector 'li.active', text: 'Dropdowns'
		end
		
		it "has correct fields on form" do
	    should have_field 'Name'
			should have_field 'Description', type: 'textarea'
			should have_field 'Active'
			should have_field 'Inactive'
			should have_link 'Cancel', href: admin_dropdowns_path(type: 'UserRole')
		end
		
		context "with error" do
			it "shows error message" do
				click_button 'Create'
		
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create User Role" do
				expect { click_button 'Create' }.not_to change(Dropdown, :count)
			end
		end
	
		context "with valid info" do
			it "creates new User Role" do
		  	new_name = Faker::Lorem.word
				fill_in "Name", with: new_name
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Dropdowns | User Roles'
				should have_content new_name
			end
		end
	end

	context "#edit" do
		before do
			log_in
			@dropdown = FactoryGirl.create(:dropdown, :user_role)
  		click_link "Administration"
			click_link "Dropdowns"
			select "UserRole", from: 'type'
			click_button 'Search'
	  	click_link @dropdown.name
		end
		
		it "has correct title" do	
	  	should have_title 'Edit Dropdown | User Role'
			should have_selector 'h1', text: 'User Roles'
			should have_selector 'h1 small', text: 'Edit'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Administration'
			should have_selector 'li.active', text: 'Dropdowns'
		end
		
		it "has correct fields on form" do
	    should have_field 'Name'
			should have_field 'Description', type: 'textarea'
			should have_field 'Active'
			should have_field 'Inactive'
			should have_link 'Cancel', href: admin_dropdowns_path(type: 'UserRole')
		end
		
	  it "record with error" do
	  	fill_in "Name", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "record with valid info saves user role" do
			new_name = Faker::Lorem.word
			fill_in "Name", with: new_name
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Dropdowns | User Roles'
			should have_content new_name
		end
	end
	
	context "#destroy" do
		before do
			log_in
			@dropdown = FactoryGirl.create(:dropdown, :user_role)
  		click_link "Administration"
			click_link "Dropdowns"
			select "UserRole", from: 'type'
			click_button 'Search'
			click_link "delete_#{@dropdown.id}"
		end
		
		it "deletes the record" do
			should have_selector 'div.alert-success'
			should have_title 'Dropdowns | User Roles'
			should_not have_content @dropdown.name
		end
	end
	
	describe "#sort" do
		before do
  		log_in
  		@dropdown = FactoryGirl.create(:dropdown, :user_role)
	  	
  		click_link "Administration"
			click_link "Dropdowns"
		end
		
  	it "has sort drag handle for All" do
			select "UserRole", from: 'type'
			select "All", from: 'status'
			click_button 'Search'
			
			should have_selector '.handle'
		end
		
  	it "has NO sort drag handle for Active" do
			select "UserRole", from: 'type'
			select "Active", from: 'status'
			click_button 'Search'
			
			should_not have_selector '.handle'
		end
		
  	it "has NO sort drag handle for Inactive" do
			select "UserRole", from: 'type'
			select "Inactive", from: 'status'
			click_button 'Search'
			
			should_not have_selector '.handle'
		end
  end
end
