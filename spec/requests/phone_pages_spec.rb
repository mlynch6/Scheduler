require 'spec_helper'

describe "Phone Pages:" do
	subject { page }
	
	context "#new" do
		context "for Account" do
			before do
				log_in
				click_link 'Home'
				click_link 'My Account'
		  	click_link 'Add Phone Number'
			end
			
			it "has correct title" do
				should have_title 'Add Phone Number'
				should have_selector 'h1', text: 'Phone Number'
				should have_selector 'h1 small', text: 'Add'
			end
			
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Home'
				should have_selector 'li.active', text: 'My Account'
			end
			
			it "has correct fields on form" do
				should have_select 'Phone Type'
		    should have_field 'Phone #'
				should have_link 'Cancel', href: account_path(current_account)
			end
			
			context "with error" do
				it "shows error message" do
			  	click_button 'Create'
			
					should have_selector 'div.alert-danger'
				end
				
				it "doesn't create Phone Number" do
					expect { click_button 'Create' }.not_to change(Phone, :count)
				end
			end
		
			context "with valid info" do
				it "creates new Phone Number" do
			  	new_phone = '888-777-7666'
			  	
			  	select "Cell", from: "Phone Type"
			  	fill_in "Phone #", with: new_phone
					click_button 'Create'
			
					should have_selector 'div.alert-success'
					should have_title 'Account'
					
					should have_content "Cell:"
					should have_content new_phone
				end
			end
		end
		
		context "for Employee" do
			before do
				log_in
				@employee = FactoryGirl.create(:employee, account: current_account)
				click_link 'People'
				click_link 'Employees'
		  	click_link @employee.name
		  	click_link 'Add Phone Number'
			end
			
			it "has correct title" do
				should have_title 'Add Phone Number'
				should have_selector 'h1', text: 'Phone Number'
				should have_selector 'h1 small', text: 'Add'
			end
			
			it "has correct Navigation" do		
				should have_selector 'li.active', text: 'People'
				should have_selector 'li.active', text: 'Employees'
			end
			
			it "has correct fields on form" do
				should have_select 'Phone Type'
		    should have_field 'Phone #'
				should have_link 'Cancel', href: employee_path(@employee)
			end
			
			context "with error" do
				it "shows error message" do
			  	click_button 'Create'
			
					should have_selector 'div.alert-danger'
				end
				
				it "doesn't create Phone Number" do
					expect { click_button 'Create' }.not_to change(Phone, :count)
				end
			end
		
			context "with valid info" do
				it "creates new Phone Number" do
			  	new_phone = '887-666-4444'
			  	
			  	select "Cell", from: "Phone Type"
			  	fill_in "Phone #", with: new_phone
					click_button 'Create'
			
					should have_selector 'div.alert-success'
					should have_title @employee.full_name
					
					should have_content "Cell:"
					should have_content new_phone
				end
			end
		end
	end

	context "#edit" do
		context "for Account" do
			before do
				log_in
				@phone = FactoryGirl.create(:phone, phoneable: current_account)
				click_link 'Home'
				click_link 'My Account'
		  	click_link "edit_phone_#{@phone.id}"
			end
			
			it "has correct title" do	
		  	should have_title 'Edit Phone Number'
				should have_selector 'h1', text: 'Phone Number'
				should have_selector 'h1 small', text: 'Edit'
			end
			
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Home'
				should have_selector 'li.active', text: 'My Account'
			end
			
			it "has correct fields on form" do
				should have_select 'Phone Type'
		    should have_field 'Phone #'
				should have_link 'Cancel', href: account_path(current_account)
			end
			
			it "with error shows error message" do
				fill_in "Phone #", with: ""
		  	click_button 'Update'
		
				should have_selector 'div.alert-danger'
			end
		
			it "record with valid info saves address" do
		  	new_phone = '543-863-5309'
		  	
		  	select "Work", from: "Phone Type"
		  	fill_in "Phone #", with: new_phone
				click_button 'Update'
		
				should have_selector 'div.alert-success'
				should have_title 'Account'
				
				should have_content "Work:"
				should have_content new_phone
			end
		end
		
		context "for Employee" do
			before do
				log_in
				@employee = FactoryGirl.create(:employee, account: current_account)
				@phone = FactoryGirl.create(:phone, phoneable: @employee)
				click_link 'People'
				click_link 'Employees'
		  	click_link @employee.name
		  	click_link "edit_phone_#{@phone.id}"
			end
			
			it "has correct title" do
		  	should have_title 'Edit Phone Number'
				should have_selector 'h1', text: 'Phone Number'
				should have_selector 'h1 small', text: 'Edit'
			end
			
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'People'
				should have_selector 'li.active', text: 'Employees'
			end
			
			it "has correct fields on form" do
				should have_select 'Phone Type'
		    should have_field 'Phone #'
				should have_link 'Cancel', href: employee_path(@employee)
			end
			
			it "with error shows error message" do
				fill_in "Phone #", with: ""
		  	click_button 'Update'
		
				should have_selector 'div.alert-danger'
			end
		
			it "record with valid info saves address" do
		  	new_phone = '543-863-5309'
		  	
		  	select "Work", from: "Phone Type"
		  	fill_in "Phone #", with: new_phone
				click_button 'Update'
		
				should have_selector 'div.alert-success'
				should have_title @employee.full_name
				
				should have_content "Work:"
				should have_content new_phone
			end
		end
	end
	
	context "#destroy" do
		context "for Account" do
			before do
				log_in
				@phone = FactoryGirl.create(:phone, phoneable: current_account)
				click_link 'Home'
				click_link 'My Account'
				click_link "delete_phone_#{@phone.id}"
			end
			
			it "deletes the phone record" do	
				should have_selector 'div.alert-success'
				should have_title 'My Account'
				
				should_not have_content "#{@phone.phone_type}:"
				should_not have_content @phone.phone_num
			end
		end
		
		context "for Employee" do
			before do
				log_in
				@employee = FactoryGirl.create(:employee, account: current_account)
				@phone = FactoryGirl.create(:phone, phoneable: @employee)
				click_link 'People'
				click_link 'Employees'
		  	click_link @employee.name
		  	click_link "delete_phone_#{@phone.id}"
			end
			
			it "deletes the phone record" do
				should have_selector 'div.alert-success'
				should have_title @employee.full_name
				
				should_not have_content "#{@phone.phone_type}:"
				should_not have_content @phone.phone_num
			end
		end
	end
end
