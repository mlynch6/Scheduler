require 'spec_helper'

describe "Account Pages:" do
  subject { page }
	
	context "#new" do	  
	  it "Invalid Signup shows error" do
	  	visit signup_path
	  	click_button "Create Account"
    	
    	should have_selector('title', text: 'Create Account')
    	should have_selector('h1', text: 'Create an Account')
    	should have_selector('div.alert-error')
    	should have_link('Terms of Service')
    	should have_link('Privacy')
    end
    
    describe "valid Signup" do
    	let(:company_name) { "New York City Ballet #{Time.now}" }
    	before do
    		visit signup_path
    		fill_in "Company", with: company_name
    		fill_in "Phone #", with: "414-543-1000"
    		select  "(GMT-08:00) Pacific Time (US & Canada)", from: "Time Zone"
		  	
		  	fill_in "Address", with: Faker::Address.street_address
				fill_in "Address 2", with: Faker::Address.street_address
				fill_in "City", with: Faker::Address.city
				select "New York", from: "State"
				fill_in "Zip Code", with: Faker::Address.zip.first(5)
    		
    		fill_in "First Name", with: "Peter"
    		fill_in "Last Name", with: "Martin"
    		select  "Artistic Director", from: "Role"
    		fill_in "Email", with: "peter.martin@nycb.org"
    		
    		fill_in "Username", with: "pmartin"
    		fill_in "Password", with: "password"
    		fill_in "Confirm Password", with: "password"
    	end
    	
    	it "creates the Account" do
    		click_button "Create Account"
    		should have_selector('div.alert-success')
    		should have_content(company_name)
    	end
    	
    	it "creates the Agma Profile" do
				expect { click_button "Create Account" }.to change(AgmaProfile.unscoped, :count).by(1)
    	end
    	
    	it "creates an Address" do
				expect { click_button "Create Account" }.to change(Address.unscoped, :count).by(1)
				Address.unscoped.last.addr_type.should == "Work"
    	end
    	
    	it "creates an Employee" do
				expect { click_button "Create Account" }.to change(Employee.unscoped, :count).by(1)
    	end
    	
    	it "creates a User" do
				expect { click_button "Create Account" }.to change(User.unscoped, :count).by(1)
    		User.unscoped.last.role.should == "Administrator"
    	end
    	
    	it "redirects to Sign In page" do
    		click_button "Create Account"
    		should have_selector('title', text: 'Sign In')
    	end
    end
	end
	
	context "#show" do
		it "has correct title" do
			log_in
			click_link "Administration"
			click_link "Company Information"
	  	
	  	should have_selector('title', text: 'Company Information')
			should have_selector('h1', text: 'Company Information')
		end
		
		it "has addresses shown" do
			log_in
			3.times { FactoryGirl.create(:address, addressable: current_account) }
			visit account_path(current_account)

			should have_selector('h2', text: 'Addresses')
			current_account.addresses.each do |address|
				should have_content("#{address.addr_type} Address")
				should have_content(address.addr)
				should have_content(address.addr2) if address.addr2.present?
				should have_content(address.city)
				should have_content(address.state)
				should have_content(address.zipcode)
				
				should have_link('Edit', href: edit_account_address_path(current_account, address))
				should have_link('Delete', href: account_address_path(current_account, address))
			end
	    should have_link('Add Address')
		end
		
		it "has Options links" do
			log_in
			visit account_path(current_account)
	  	
	  	should have_link('Edit')
		end
		
		it "displays correct data" do
			log_in
			visit account_path(current_account)
	  	
			should have_selector('div.text-ui', text: current_account.name)
			should have_selector('div.text-ui', text: current_account.main_phone)
			should have_selector('div.text-ui', text: current_account.time_zone)
		end
	end
	
	context "#edit" do
		it "has correct title" do
			log_in
			click_link "Administration"
			click_link "Company Information"
			click_link "Edit"
	  	
	  	should have_selector('title', text: 'Edit Company Information')
			should have_selector('h1', text: 'Edit Company Information')
		end
		
	  it "record with error" do
	  	log_in
			visit edit_account_path(current_account)
	  	fill_in "Phone #", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-error')
		end
	
		it "with bad record in URL shows current account" do
pending
			log_in
			visit edit_account_path(0)
	
			should have_selector('title', text: 'Company Info')
			should have_content(current_account.name)
		end
		
		it "record with wrong account shows current account" do
pending
			wrong_account = FactoryGirl.create(:account)
			log_in
			visit edit_account_path(wrong_account)
	
			should have_selector('title', text: 'Company Info')
			should have_content(current_account.name)
		end
	 
		it "record with valid info saves account" do
			log_in
			visit edit_account_path(current_account)
			should have_content(current_account.name)
			
    	fill_in "Phone #", with: "414-888-0000"
    	select  "(GMT-10:00) Hawaii", from: "Time Zone"
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Company Information')
			
			should have_selector('div.text-ui', text: current_account.name)
			should have_selector('div.text-ui', text: "414-888-0000")
			should have_selector('div.text-ui', text: "Hawaii")
		end
	end
end
