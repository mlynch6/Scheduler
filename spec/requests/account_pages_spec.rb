require 'spec_helper'

describe "Account Pages:" do
  subject { page }
	
	context "#new" do
		before do
			visit root_path
			click_link "Pricing & Signup"
			click_link "Sign Up"
		end
		
		it "has correct title" do	  	
	  	has_title?('Create Account').should be_true
	    should have_selector('h1', text: 'Create an Account')
	    should have_link('Terms of Service')
	    should have_link('Privacy')
		end
		
		it "has correct fields on form" do	  	
	  	has_field?('Company').should be_true
	    has_select?('Time Zone').should be_true
	    has_field?('Phone #').should be_true
	    
	    has_field?('Address').should be_true
	    has_field?('Address 2').should be_true
	    has_field?('City').should be_true
	    has_select?('State').should be_true
	    has_field?('Zip Code').should be_true
	    
	    has_field?('First Name').should be_true
	    has_field?('Last Name').should be_true
	    has_select?('Role').should be_true
	    has_field?('Email').should be_true
	    
	    has_field?('Username').should be_true
	    has_field?('Password').should be_true
	    has_field?('Confirm Password').should be_true
	    
	    has_field?('Credit Card Number').should be_true
	    has_select?('card_month').should be_true
	    has_select?('card_year').should be_true
	    has_field?('Security Code').should be_true
		end
		
	  describe "invalid Signup" do
		  it "with invalid credit card number shows error", js: true do
		  	fill_in "Credit Card Number", with: "4242424242424241"
		  	select (Date.today.year+1).to_s, from: "card_year"
		  	fill_in "Security Code", with: "213"
		  	click_button "Create Account"
	    	
	    	should have_selector('div.alert-danger')
	    	should have_content('card number is incorrect')
	    end
	    
	    it "with invalid credit card CVC shows error", js: true do
		  	fill_in "Credit Card Number", with: "4242424242424242"
		  	select (Date.today.year+1).to_s, from: "card_year"
		  	fill_in "Security Code", with: "99"
		  	click_button "Create Account"
	    	
	    	should have_selector('div.alert-danger')
	    	should have_content('security code is invalid')
	    end
		  
		  it "valid credit card with incomplete account information shows error", js: true do
		  	fill_in "Credit Card Number", with: "378282246310005" #valid testing Am Ex
		  	select (Date.today.year+1).to_s, from: "card_year"
		  	fill_in "Security Code", with: "213"
		  	click_button "Create Account"
	    	
	    	should have_selector('div.alert-danger')
	    	should have_content('Credit Card has been provided')
	    end
	    
	    it "with card declined error", js: true do
	    	company_name = "New York City Ballet #{Time.now}"
    		username = "pmartin#{DateTime.now.seconds_since_midnight}"
    	
	    	fill_in "Company", with: company_name
    		select  "(GMT-08:00) Pacific Time (US & Canada)", from: "Time Zone"
    		fill_in "Phone #", with: "414-543-1000"
		  	
		  	fill_in "Address", with: Faker::Address.street_address
				fill_in "Address 2", with: Faker::Address.street_address
				fill_in "City", with: Faker::Address.city
				select "New York", from: "State"
				fill_in "Zip Code", with: Faker::Address.zip.first(5)
    		
    		fill_in "First Name", with: "Peter"
    		fill_in "Last Name", with: "Martin"
    		select  "Artistic Director", from: "Role"
    		fill_in "Email", with: "peter.martin@nycb.org"
    		
    		fill_in "Username", with: username
    		fill_in "Password", with: "password"
    		fill_in "Confirm Password", with: "password"
    		
		  	fill_in "Credit Card Number", with: "4000000000000002" #always returns card declined
		  	select (Date.today.year+1).to_s, from: "card_year"
		  	fill_in "Security Code", with: "213"
		  	click_button "Create Account"
	    	
	    	should have_selector('div.alert-danger')
	    	should have_content('card was declined')
	    	should have_content('Credit Card Number')
	    end
	  end
    
    describe "valid Signup" do
    	let(:company_name) { "New York City Ballet #{Time.now}" }
    	let(:username) { "pmartin#{DateTime.now.seconds_since_midnight}" }
    	before do
    		fill_in "Company", with: company_name
    		select  "(GMT-08:00) Pacific Time (US & Canada)", from: "Time Zone"
    		fill_in "Phone #", with: "414-543-1000"
		  	
		  	fill_in "Address", with: Faker::Address.street_address
				fill_in "Address 2", with: Faker::Address.street_address
				fill_in "City", with: Faker::Address.city
				select "New York", from: "State"
				fill_in "Zip Code", with: Faker::Address.zip.first(5)
    		
    		fill_in "First Name", with: "Peter"
    		fill_in "Last Name", with: "Martin"
    		select  "Artistic Director", from: "Role"
    		fill_in "Email", with: "peter.martin@nycb.org"
    		
    		fill_in "Username", with: username
    		fill_in "Password", with: "password"
    		fill_in "Confirm Password", with: "password"
    		
    		fill_in "Credit Card Number", with: "378282246310005" #valid testing Am Ex
		  	select (Date.today.year+1).to_s, from: "card_year"
		  	fill_in "Security Code", with: "213"
		  	
		  	click_button "Create Account"
		  	
		  	should have_selector('div.alert-success')
    	end
    	
    	after do
    		destroy_stripe_account(User.unscoped.find_by_username(username).account)
    	end
    	
    	it "creates the Account", js: true do
    		should have_content(company_name)
    		account = User.unscoped.find_by_username(username).account
    		account.name.should == company_name
    	end
    	
    	it "creates the Agma Contract", js: true do
				account = User.unscoped.find_by_username(username).account
				account.agma_contract.should_not be_nil
    	end
    	
    	it "creates an Address", js: true do
				account = User.unscoped.find_by_username(username).account
				account.addresses.count.should == 1
				account.addresses.first.addr_type.should == "Work"
    	end
    	
    	it "creates a Phone Number", js: true do
				account = User.unscoped.find_by_username(username).account
				account.phones.count.should == 1
				account.phones.first.phone_type.should == "Work"
    	end
    	
    	it "creates an Employee", js: true do
    		account = User.unscoped.find_by_username(username).account
				account.employees.count.should == 1
    	end
    	
    	it "creates a User", js: true do
    		user = User.unscoped.find_by_username(username)
		  	user.should_not be_nil
    		user.role.should == "Administrator"
    	end
    	
    	it "redirects to Sign In page", js: true do
    		should have_selector('h1', text: 'Sign In')
    	end
    end
	end
	
	context "#show" do
		before do
			log_in
			click_link 'Home'
			click_link 'My Account'
		end
		
		it "has correct title" do
	  	should have_title 'My Account'
			should have_selector 'h1', text: 'My Account'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Home'
			should have_selector 'li.active', text: 'My Account'
			should have_selector 'li.active', text: 'Overview'
		end
		
		it "displays correct data" do
			should have_content current_account.name
			should have_content current_account.time_zone
			should have_content current_account.status
			should have_content current_account.cancelled_at
		end
		
		it "has addresses shown" do
			3.times { FactoryGirl.create(:address, addressable: current_account) }
			visit account_path(current_account)

			should have_selector('h3', text: 'Addresses')
			current_account.addresses.each do |address|
				should have_content "#{address.addr_type} Address"
				should have_content address.addr
				should have_content address.addr2 if address.addr2.present?
				should have_content address.city
				should have_content address.state
				should have_content address.zipcode
				
				should have_link 'Edit', href: edit_account_address_path(current_account, address)
				should have_link 'Delete', href: account_address_path(current_account, address)
			end
		end
		
		it "without address records" do
	    should have_selector 'p', text: 'To begin, click the Add Address link above.'
		end
		
		it "has phone numbers shown" do
			3.times { FactoryGirl.create(:phone, phoneable: current_account) }
			visit account_path(current_account)

			should have_selector 'h3', text: 'Phone Numbers'
			current_account.phones.each do |phone|
				should have_content "#{phone.phone_type}:"
				should have_content phone.phone_num
				
				should have_link 'Edit', href: edit_account_phone_path(current_account, phone)
				should have_link 'Delete', href: account_phone_path(current_account, phone)
			end
		end
		
		it "without phone records" do
	    should have_selector 'p', text: 'To begin, click the Add Phone Number link above.'
		end
		
		it "has links for Super Admin" do
	  	should have_link current_account.name
			
	  	should have_link 'Overview'
			should have_link 'Subscription'
			
	  	should have_link 'Add Address'
	  	should have_link 'Add Phone Number'
			should have_link 'Change Payment Method'
		end
	end
	
	context "#edit" do
		before do
			log_in
			click_link 'Home'
			click_link 'My Account'
			click_link current_account.name
		end
		
		it "has correct title" do
	  	should have_title 'Edit Account'
			should have_selector 'h1', text: 'My Account'
			should have_selector 'h1 small', text: 'Edit'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Home'
			should have_selector 'li.active', text: 'My Account'
			should have_selector('li.active', text: 'Overview')
		end
		
		it "has correct fields on form" do	  	
	    should have_select 'Time Zone'
			should have_link 'Cancel', href: account_path(current_account)
		end
		
	  it "record with error" do
			pending "No field can currently cause an error"
	  	fill_in "Company", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "record with valid info saves account" do
			should have_content current_account.name
			
    	select  "(GMT-10:00) Hawaii", from: "Time Zone"
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'My Account'
			
			should have_content "Hawaii"
		end
		
		it "has links for Super Admin" do
	  	should have_link 'Overview'
			should have_link 'Subscription'
			
			should have_link 'Add Address'
	  	should have_link 'Add Phone Number'
			should have_link 'Change Payment Method'
		end
	end
end
