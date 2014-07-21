require 'spec_helper'

describe "Address Pages:" do
	subject { page }
	
	context "Account" do
		context "#new" do
			before do
				log_in
				click_link 'Home'
				click_link 'My Account'
		  	click_link 'Add Address'
			end
			
			it "has correct title" do
				should have_title 'Add Address'
				should have_selector 'h1', text: 'Address'
				should have_selector 'h1 small', text: 'Add'
			end
			
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Home'
				should have_selector 'li.active', text: 'My Account'
			end
			
			it "has correct fields on form" do
		  	should have_select 'Address Type'
		    should have_field 'Address'
		    should have_field 'Address 2'
		    should have_field 'City'
		    should have_select 'State'
		    should have_field 'Zip Code'
				should have_link 'Cancel', href: account_path(current_account)
			end
			
			context "with error" do
				it "shows error message" do
			  	click_button 'Create'
			
					should have_selector 'div.alert-danger'
				end
				
				it "doesn't create Address" do
					expect { click_button 'Create' }.not_to change(Address, :count)
				end
			end
		
			context "with valid info" do
				it "creates new Address" do
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
			
					should have_selector 'div.alert-success'
					should have_title 'Account'
					
					should have_content "Work Address"
					should have_content new_addr
					should have_content new_addr2
					should have_content new_city
					should have_content "AL"
					should have_content new_zip
				end
			end
		end
		
		context "#edit" do
			before do
				log_in
				@address = FactoryGirl.create(:address, addressable: current_account)
				click_link 'Home'
				click_link 'My Account'
		  	click_link "edit_address_#{@address.id}"
			end
			
			it "has correct title" do
		  	should have_title 'Edit Address'
				should have_selector 'h1', text: 'Address'
				should have_selector 'h1 small', text: 'Edit'
			end
			
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Home'
				should have_selector 'li.active', text: 'My Account'
			end
			
			it "has correct fields on form" do
		  	should have_select 'Address Type'
		    should have_field 'Address'
		    should have_field 'Address 2'
		    should have_field 'City'
		    should have_select 'State'
		    should have_field 'Zip Code'
				should have_link 'Cancel', href: account_path(current_account)
			end
			
			it "with error shows error message" do
				fill_in "Address", with: ""
		  	click_button 'Update'
		
				should have_selector'div.alert-danger'
			end
		
			it "record with valid info saves address" do
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
		
				should have_selector 'div.alert-success'
				should have_title 'Account'
				
				should have_content "Work Address"
				should have_content new_addr
				should have_content new_addr2
				should have_content new_city
				should have_content "AL"
				should have_content new_zip
			end
		end
		
		context "#destroy" do
			before do
				log_in
				@address = FactoryGirl.create(:address, addressable: current_account)
				click_link 'Home'
				click_link 'My Account'
				click_link "delete_address_#{@address.id}"
			end
			
			it "deletes the address record" do
				should have_selector 'div.alert-success'
				should have_title 'My Account'
				
				should_not have_content "#{@address.addr_type} Address"
				should_not have_content @address.addr
				should_not have_content @address.addr2 if @address.addr2.present?
				should_not have_content @address.city
				should_not have_content @address.state
				should_not have_content @address.zipcode
			end
		end
	end
	
	context "Person" do
		context "#new" do
			before do
				log_in
				@person = FactoryGirl.create(:person, account: current_account)
				@employee = @person.profile
				click_link 'People'
				click_link 'Employees'
				click_link @person.name
		  	click_link 'Add Address'
			end
			
			it "has correct title" do
				should have_title 'Add Address'
				should have_selector 'h1', text: 'Address'
				should have_selector 'h1 small', text: 'Add'
			end
			
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'People'
				should have_selector 'li.active', text: 'Employees'
			end
			
			it "has correct fields on form" do
		  	should have_select 'Address Type'
		    should have_field 'Address'
		    should have_field 'Address 2'
		    should have_field 'City'
		    should have_select 'State'
		    should have_field 'Zip Code'
				should have_link 'Cancel', href: employee_path(@employee)
			end
			
			context "with error" do
				it "shows error message" do
			  	click_button 'Create'
			
					should have_selector 'div.alert-danger'
				end
				
				it "doesn't create Address" do
					expect { click_button 'Create' }.not_to change(Address, :count)
				end
			end
		
			context "with valid info" do
				it "creates new Address" do
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
			
					should have_selector 'div.alert-success'
					should have_title @person.full_name
					
					should have_content "Work Address"
					should have_content new_addr
					should have_content new_addr2
					should have_content new_city
					should have_content "WV"
					should have_content new_zip
				end
			end
		end
		
		context "#edit" do
			before do
				log_in
				@person = FactoryGirl.create(:person, account: current_account)
				@employee = @person.profile
				@address = FactoryGirl.create(:address_person, addressable: @person)
				click_link 'People'
				click_link 'Employees'
				click_link @person.name
		  	click_link "edit_address_#{@address.id}"
			end
			
			it "has correct title" do
		  	should have_title 'Edit Address'
				should have_selector 'h1', text: 'Address'
				should have_selector 'h1 small', text: 'Edit'
			end
			
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'People'
				should have_selector 'li.active', text: 'Employees'
			end
			
			it "has correct fields on form" do
		  	should have_select 'Address Type'
		    should have_field 'Address'
		    should have_field 'Address 2'
		    should have_field 'City'
		    should have_select 'State'
		    should have_field 'Zip Code'
				should have_link 'Cancel', href: employee_path(@employee)
			end
			
			it "with error shows error message" do
				fill_in "Address", with: ""
		  	click_button 'Update'
		
				should have_selector 'div.alert-danger'
			end
		
			it "record with valid info saves address" do
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
		
				should have_selector 'div.alert-success'
				should have_title @person.full_name
				
				should have_content "Work Address"
				should have_content new_addr
				should have_content new_addr2
				should have_content new_city
				should have_content "AL"
				should have_content new_zip
			end
		end
		
		context "#destroy" do
			before do
				log_in
				@person = FactoryGirl.create(:person, account: current_account)
				@address = FactoryGirl.create(:address_person, addressable: @person)
				click_link 'People'
				click_link 'Employees'
				click_link @person.name
				click_link "delete_address_#{@address.id}"
			end
			
			it "deletes the address record" do
				should have_selector 'div.alert-success'
				should have_title @person.full_name
				
				should_not have_content "#{@address.addr_type} Address"
				should_not have_content @address.addr
				should_not have_content @address.addr2 if @address.addr2.present?
				should_not have_content @address.city
				should_not have_content @address.state
				should_not have_content @address.zipcode
			end
		end
	end
end
