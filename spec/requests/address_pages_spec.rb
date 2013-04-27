require 'spec_helper'

describe "Address Pages:" do
	subject { page }
	
	context "#new" do
		context "for Account" do
			it "has correct title" do
				log_in
				click_link "Administration"
		  	click_link 'Add Address'
		
				should have_selector('title', text: 'Add Address')
				should have_selector('h1', text: 'Add Address')
			end
			
			context "with error" do
				it "shows error message" do
					log_in
					visit new_account_address_path(current_account)
			  	click_button 'Create'
			
					should have_selector('div.alert-error')
				end
				
				it "doesn't create Address" do
					log_in
					visit new_account_address_path(current_account)
			
					expect { click_button 'Create' }.not_to change(Address, :count)
				end
			end
		
			context "with valid info" do
				it "creates new Address" do
					log_in
					visit new_account_address_path(current_account)
					
			  	new_addr = Faker::Address.street_address
			  	new_addr2 = Faker::Address.street_address
			  	new_city = Faker::Address.city
			  	new_zip = Faker::Address.zip.first(5)
			  	
			  	select "Work", from: "Address Type"
			  	fill_in "Address", with: new_addr
					fill_in "Address 2", with: new_addr2
					fill_in "City", with: new_city
					select "Alabama", from: "State"
					fill_in "Zip Code", with: new_zip
					click_button 'Create'
			
					should have_selector('div.alert-success')
					should have_selector('title', text: 'Company Information')
					
					should have_content("Work Address")
					should have_content(new_addr)
					should have_content(new_addr2)
					should have_content(new_city)
					should have_content("AL")
					should have_content(new_zip)
				end
			end
		end
		
		context "for Employee" do
			it "has correct title" do
				log_in
				click_link "Employees"
		  	click_link "View"
		  	click_link 'Add Address'
		
				should have_selector('title', text: 'Add Address')
				should have_selector('h1', text: 'Add Address')
			end
			
			context "with error" do
				it "shows error message" do
					log_in
					employee = FactoryGirl.create(:employee, account: current_account)
					visit new_employee_address_path(employee)
			  	click_button 'Create'
			
					should have_selector('div.alert-error')
				end
				
				it "doesn't create Address" do
					log_in
					employee = FactoryGirl.create(:employee, account: current_account)
					visit new_employee_address_path(employee)
			
					expect { click_button 'Create' }.not_to change(Address, :count)
				end
			end
		
			context "with valid info" do
				it "creates new Address" do
					log_in
					employee = FactoryGirl.create(:employee, account: current_account)
					visit new_employee_address_path(employee)
					
			  	new_addr = Faker::Address.street_address
			  	new_addr2 = Faker::Address.street_address
			  	new_city = Faker::Address.city
			  	new_zip = Faker::Address.zip.first(5)
			  	
			  	select "Work", from: "Address Type"
			  	fill_in "Address", with: new_addr
					fill_in "Address 2", with: new_addr2
					fill_in "City", with: new_city
					select "West Virginia", from: "State"
					fill_in "Zip Code", with: new_zip
					click_button 'Create'
			
					should have_selector('div.alert-success')
					should have_selector('title', text: 'Employee')
					
					should have_content("Work Address")
					should have_content(new_addr)
					should have_content(new_addr2)
					should have_content(new_city)
					should have_content("WV")
					should have_content(new_zip)
				end
			end
		end
	end

	context "#edit" do
		context "for Account" do
			it "has correct title" do
				log_in
				address = FactoryGirl.create(:address, addressable: current_account)
				click_link "Administration"
		  	click_link "edit_address_#{address.id}"
		  	
		  	should have_selector('title', text: 'Update Address')
				should have_selector('h1', text: 'Update Address')
			end
			
			it "with error shows error message" do
				log_in
				address = FactoryGirl.create(:address, addressable: current_account)
				visit edit_account_address_path(current_account, address)
				
				fill_in "Address", with: ""
		  	click_button 'Update'
		
				should have_selector('div.alert-error')
			end
		
			it "record with valid info saves address" do
				log_in
				address = FactoryGirl.create(:address, addressable: current_account)
				visit edit_account_address_path(current_account, address)
				
		  	new_addr = Faker::Address.street_address
		  	new_addr2 = Faker::Address.street_address
		  	new_city = Faker::Address.city
		  	new_zip = Faker::Address.zip.first(5)
		  	
		  	select "Work", from: "Address Type"
		  	fill_in "Address", with: new_addr
				fill_in "Address 2", with: new_addr2
				fill_in "City", with: new_city
				select "Alabama", from: "State"
				fill_in "Zip Code", with: new_zip
				click_button 'Update'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Company Information')
				
				should have_content("Work Address")
				should have_content(new_addr)
				should have_content(new_addr2)
				should have_content(new_city)
				should have_content("AL")
				should have_content(new_zip)
			end
		end
		
		context "for Employee" do
			it "has correct title" do
				log_in
				employee = FactoryGirl.create(:employee, account: current_account)
				address = FactoryGirl.create(:address_employee, addressable: employee)
				click_link "Employees"
				click_link "show_#{employee.id}"
		  	click_link "edit_address_#{address.id}"
		  	
		  	should have_selector('title', text: 'Update Address')
				should have_selector('h1', text: 'Update Address')
			end
			
			it "with error shows error message" do
				log_in
				employee = FactoryGirl.create(:employee, account: current_account)
				address = FactoryGirl.create(:address_employee, addressable: employee)
				visit edit_employee_address_path(employee, address)
				
				fill_in "Address", with: ""
		  	click_button 'Update'
		
				should have_selector('div.alert-error')
			end
		
			it "record with valid info saves address" do
				log_in
				employee = FactoryGirl.create(:employee, account: current_account)
				address = FactoryGirl.create(:address_employee, addressable: employee)
				visit edit_employee_address_path(employee, address)
				
		  	new_addr = Faker::Address.street_address
		  	new_addr2 = Faker::Address.street_address
		  	new_city = Faker::Address.city
		  	new_zip = Faker::Address.zip.first(5)
		  	
		  	select "Work", from: "Address Type"
		  	fill_in "Address", with: new_addr
				fill_in "Address 2", with: new_addr2
				fill_in "City", with: new_city
				select "Alabama", from: "State"
				fill_in "Zip Code", with: new_zip
				click_button 'Update'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Employee')
				
				should have_content("Work Address")
				should have_content(new_addr)
				should have_content(new_addr2)
				should have_content(new_city)
				should have_content("AL")
				should have_content(new_zip)
			end
		end
	end
	
	context "#destroy" do
		context "for Account" do
			it "deletes the address record" do
				log_in
				address = FactoryGirl.create(:address, addressable: current_account)
				visit account_path(current_account)
				click_link "delete_address_#{address.id}"
				
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Company Information')
				
				should_not have_content("#{address.addr_type} Address")
				should_not have_content(address.addr)
				should_not have_content(address.addr2) if address.addr2.present?
				should_not have_content(address.city)
				should_not have_content(address.state)
				should_not have_content(address.zipcode)
			end
		end
		
		context "for Employee" do
			it "deletes the address record" do
				log_in
				employee = FactoryGirl.create(:employee, account: current_account)
				address = FactoryGirl.create(:address_employee, addressable: employee)
				visit employee_path(employee)
				click_link "delete_address_#{address.id}"
				
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Employee')
				
				should_not have_content("#{address.addr_type} Address")
				should_not have_content(address.addr)
				should_not have_content(address.addr2) if address.addr2.present?
				should_not have_content(address.city)
				should_not have_content(address.state)
				should_not have_content(address.zipcode)
			end
		end
	end
end
