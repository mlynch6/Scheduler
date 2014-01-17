require 'spec_helper'

describe "Event Pages:" do
	subject { page }
  
  context "#index" do
  	it "has correct title & headers" do
			log_in
			click_link "Calendar"
	  	click_link "Daily Schedule"
	  	
	  	should have_selector('title', text: 'Daily Schedule')
		 	
		  should have_selector('h2', text: Time.zone.today.strftime('%A, %B %-d, %Y'))
		  should have_content(Time.zone.today.strftime('%A'))
		end
		
		it "has correct Navigation" do
			log_in
			visit events_path
	
			should have_selector('li.active', text: 'Calendar')
			should have_selector('li.active', text: 'Daily Schedule')
		end
		
		it "without records" do
			log_in
	  	visit events_path
	  	
			should_not have_selector('div.event')
		end
	  
		it "lists records" do
			log_in
			loc1 = FactoryGirl.create(:location, account: current_account)
			loc2 = FactoryGirl.create(:location, account: current_account)		
			FactoryGirl.create(:event,
					account: current_account,
					location: loc1,
					start_date: Time.zone.today)
			FactoryGirl.create(:event,
					account: current_account,
					location: loc2,
					start_date: Time.zone.today)
			visit events_path
	
			Event.for_daily_calendar(Time.zone.today).each do |event|
				should have_selector('div', text: event.title)
				should have_selector('div', text: event.location.name)
				should have_content(event.start_at.to_s(:hr12))
				should have_content(event.end_at.to_s(:hr12))
	    end
		end
		
		it "lists Rehearsal records" do
			log_in
			loc = FactoryGirl.create(:location, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)	
			FactoryGirl.create(:rehearsal,
					account: current_account,
					location: loc,
					piece: piece,
					start_date: Time.zone.today)
			visit events_path
	
			Event.for_daily_calendar(Time.zone.today).each do |rehearsal|
				should have_selector('div', text: rehearsal.title)
				should have_selector('div', text: rehearsal.location.name)
				should have_content(event.start_at.to_s(:hr12))
				should have_content(event.end_at.to_s(:hr12))
				should have_selector('div', text: rehearsal.piece.name)
				
				should have_link('Edit', href: edit_rehearsal_path)
	    end
		end
		
		it "shows Rehearsal details in popup window" do
			pending "How to test modal dialog?"
		end
		
		it "lists Company Class records" do
			log_in
			loc = FactoryGirl.create(:location, account: current_account)
			FactoryGirl.create(:company_class,
					account: current_account,
					location: loc,
					start_date: Time.zone.today)
			visit events_path
	
			Event.for_daily_calendar(Time.zone.today).each do |company_class|
				should have_selector('div', text: company_class.title)
				should have_selector('div', text: company_class.location.name)
				should have_content(company_class.start_at.to_s(:hr12))
				should have_content(company_class.end_at.to_s(:hr12))
				
				should have_link('Edit', href: edit_company_class_path)
	    end
		end
		
		it "shows Company Class break" do
			log_in
			loc = FactoryGirl.create(:location, account: current_account)
			profile = current_account.agma_profile
			FactoryGirl.create(:company_class,
					account: current_account,
					location: loc,
					start_date: Time.zone.today)
			visit events_path
	
			Event.for_daily_calendar(Time.zone.today).each do |company_class|
				should have_content("#{profile.class_break_min} min Break")
	    end
		end
		
		it "does not show Company Class break if contract break is 0" do
			log_in
			loc = FactoryGirl.create(:location, account: current_account)
			profile = AgmaProfile.find_by_account_id(current_account.id)
			profile.class_break_min = 0
			profile.save
			
			FactoryGirl.create(:company_class,
					account: current_account,
					location: loc,
					start_date: Time.zone.today)
			visit events_path
	
			Event.for_daily_calendar(Time.zone.today).each do |company_class|
				should_not have_content("#{profile.class_break_min} min Break")
	    end
		end
		
		it "shows Company Class details in popup window" do
			pending "How to test modal dialog?"
		end
		
		it "lists Costume Fitting records" do
			log_in
			loc = FactoryGirl.create(:location, account: current_account)
			FactoryGirl.create(:costume_fitting,
					account: current_account,
					location: loc,
					start_date: Time.zone.today)
			visit events_path
	
			Event.for_daily_calendar(Time.zone.today).each do |costume_fitting|
				should have_selector('div', text: costume_fitting.title)
				should have_selector('div', text: costume_fitting.location.name)
				should have_content(costume_fitting.start_at.to_s(:hr12))
				should have_content(costume_fitting.end_at.to_s(:hr12))
				
				should have_link('Edit', href: edit_costume_fitting_path)
	    end
		end
		
		it "shows Costume Fitting details in popup window" do
			pending "How to test modal dialog?"
		end
		
		it "has links for Super Admin" do
			log_in_admin
			location = FactoryGirl.create(:location, account: current_account)
			FactoryGirl.create(:event, account: current_account, location: location)
			visit events_path
	
			should have_link('New Company Class')
			should have_link('New Rehearsal')
			should have_link('New Costume Fitting')
		end
		
		it "doesn't have links for Employee" do
			log_in_employee
			location = FactoryGirl.create(:location, account: current_account)
			FactoryGirl.create(:event, account: current_account, location: location)
			visit events_path
	
			should_not have_link('New Company Class')
			should_not have_link('New Rehearsal')
			should_not have_link('New Costume Fitting')
		end
		
		it "has links for Administrator" do
			log_in_admin
			location = FactoryGirl.create(:location, account: current_account)
			FactoryGirl.create(:event, account: current_account, location: location)
			visit events_path
	
			should have_link('New Company Class')
			should have_link('New Rehearsal')
			should have_link('New Costume Fitting')
		end
		
		describe "sidenav calendar" do
			let(:username) { "pmartin#{DateTime.now.seconds_since_midnight}" }
    	before do
    		visit root_path
				click_link "Pricing & Signup"
				click_link "Sign Up"
    		
    		fill_in "Company", with: "Event Sidenav Calendar #{Time.now}"
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
		  	fill_in "username", with: username
	  		fill_in "password", with: "password"
	  		click_button "Sign In"
	  		page.should have_content "Sign Out"
    	end
    	
    	after do
    		destroy_stripe_account(User.unscoped.find_by_username(username).account)
    	end
    	
			it "navigates to correct day", js: true do
				visit events_path+"/2014/1/1"
				should have_selector('h2', text: "January 1, 2014")
				
				click_link '3'
				should have_selector('h1', text: 'Daily Schedule')
				should have_selector('h2', text: "January 3, 2014")
			end
		end
	end
end
