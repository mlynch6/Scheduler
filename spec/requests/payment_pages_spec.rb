require 'spec_helper'

describe "Payment Pages:" do
  subject { page }
	
	context "#edit" do
		#log_in function not working with js: true option
		let(:company_name) { "New York City Ballet #{Time.now}" }
  	let(:username) { "pmartin#{DateTime.now.seconds_since_midnight}" }
		
  	before do
  		visit signup_path(plan: 1)
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
	  	
	  	visit login_path
	  	fill_in "Username", with: username
  		fill_in "Password", with: "password"
  		click_button "Sign In"
  		page.should have_content "Sign Out"
  		
  		visit subscriptions_current_path
  		click_link "Change Payment Method"
  	end
  	
  	after do
  		destroy_stripe_account(User.unscoped.find_by_username(username).account)
  	end
		
		it "has correct title", js: true do
	  	#should have_selector('title', text: 'Change Payment Method')
			should have_selector('h1', text: 'Change Payment Method')
		end
		
		it "has links", js: true do
	  	should have_link('My Subscription')
		end
		
		it "can update the credit card", js: true do
    	fill_in "Credit Card Number", with: "5105105105105100" #valid testing Mastercard
		  select (Date.today.year+1).to_s, from: "card_year"
		  fill_in "Security Code", with: "213"
		  click_button "Update"
		  
		  should have_selector('div.alert-success')
		  should have_selector('h1', text: 'My Subscription')
		end
		
		describe "invalid Payment" do
		  it "with invalid credit card number shows error", js: true do
		  	fill_in "Credit Card Number", with: "4242424242424241"
		  	select (Date.today.year+1).to_s, from: "card_year"
		  	fill_in "Security Code", with: "213"
		  	click_button "Update"
	    	
	    	should have_selector('div.alert-error')
	    	should have_content('card number is incorrect')
	    end
	    
	    it "with invalid security code shows error", js: true do
		  	fill_in "Credit Card Number", with: "4242424242424242"
		  	select (Date.today.year+1).to_s, from: "card_year"
		  	fill_in "Security Code", with: "99"
		  	click_button "Update"
	    	
	    	should have_selector('div.alert-error')
	    	should have_content('security code is invalid')
	    end
	    
	    it "with card declined error", js: true do
		  	fill_in "Credit Card Number", with: "4000000000000002" #always returns card declined
		  	select (Date.today.year+1).to_s, from: "card_year"
		  	fill_in "Security Code", with: "213"
		  	click_button "Update"
	    	
	    	should have_selector('div.alert-error')
	    	should have_content('card was declined')
	    	should have_content('Credit Card Number')
	    end
	  end
	end
end
