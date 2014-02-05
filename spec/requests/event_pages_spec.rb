require 'spec_helper'

describe "Event Pages:" do
	subject { page }
  
  context "#new" do
  	it "has correct title" do
			log_in
	  	click_link 'Calendar'
	  	visit new_event_path
	  	
	  	should have_selector('title', text: 'New Event')
		  should have_selector('h1', text: 'New Event')
		end
		
		it "has correct Navigation" do
			log_in
			visit new_event_path
	
			should have_selector('li.active', text: 'Calendar')
			should have_selector('li.active', text: 'New Event')
		end
		
		it "only shows applicable fields", js: true do
			log_in
	  	visit new_event_path
	
			should_not have_selector('label', text: 'Piece')
		end
		
		it "has only active Locations in dropdown" do
			log_in
			FactoryGirl.create(:location, account: current_account, name: 'Location A')
			FactoryGirl.create(:location_inactive, account: current_account, name: 'Location B')
			visit new_event_path
  		
			should have_selector('option', text: 'Location A')
			should_not have_selector('option', text: 'Location B')
		end
		
		it "has only active Employees in dropdown" do
			log_in
			FactoryGirl.create(:employee, account: current_account, last_name: 'Parker', first_name: 'Peter')
			FactoryGirl.create(:employee_inactive, account: current_account, last_name: 'Kent', first_name: 'Clark')
			visit new_event_path
  		
			should have_selector('option', text: 'Peter Parker')
			should_not have_selector('option', text: 'Clark Kent')
		end
		
		it "defaults Start Date when date is sent in URL" do
			log_in
			visit new_event_path(date: Time.zone.today.to_s)
			
			find_field('event_start_date').value.should == Time.zone.today.strftime("%m/%d/%Y")
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				visit new_event_path
		  	click_button 'Create'
		
				should have_selector('div.alert-danger')
			end
			
			it "doesn't create Event" do
				log_in
				visit new_event_path
		
				expect { click_button 'Create' }.not_to change(Event, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Event without Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				visit new_event_path
	  		
		  	fill_in "Title", with: "Test Event"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2013"
		  	fill_in 'Start Time', with: "10AM"
		  	fill_in 'Duration', with: 60
		  	click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Daily Schedule')
				
				should have_content("Test Event")
				should have_content(location.name)
				should have_content("10:00 AM to 11:00 AM")
			end
			
			it "creates new Event with Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account)
				visit new_event_path
	  		
		  	fill_in "Title", with: "Test Event"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2013"
		  	fill_in 'Start Time', with: "9AM"
		  	fill_in 'Duration', with: 90
		  	select e1.full_name, from: "Invitees"
				click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Daily Schedule')
				
				should have_content("Test Event")
				should have_content(location.name)
				should have_content("9:00 AM to 10:30 AM")
			end
		end
		
		context "shows warning" do			
			it "when employee is double booked" do
				log_in
				loc1 = FactoryGirl.create(:location, account: current_account)
				loc2 = FactoryGirl.create(:location, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account)
				e2 = FactoryGirl.create(:employee, account: current_account)
				e3 = FactoryGirl.create(:employee, account: current_account)
				
				event1 = FactoryGirl.create(:event, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				FactoryGirl.create(:invitation, event: event1, employee: e1)
				FactoryGirl.create(:invitation, event: event1, employee: e2)
				FactoryGirl.create(:invitation, event: event1, employee: e3)
				
				event2 = FactoryGirl.create(:event, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 60)
				FactoryGirl.create(:invitation, event: event2, employee: e1)
				
				visit new_event_path
				fill_in "Title", with: "Test Event"
		  	select loc2.name, from: "Location"
		  	fill_in 'Date', with: Time.zone.today
		  	fill_in 'Start Time', with: "11AM"
		  	fill_in 'Duration', with: 120
		  	select e1.full_name, from: "Invitees"
				click_button 'Create'
		
				should have_selector('div.alert-warning', text: "people are double booked")
				should have_selector('div.alert-warning', text: e1.full_name)
				should_not have_selector('div.alert-warning', text: e2.full_name)
				should_not have_selector('div.alert-warning', text: e3.full_name)
			end
		end
	end
	
	context "#edit" do
		it "has correct title" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event, account: current_account,
					location: location,
					start_date: Time.zone.today)
	  	click_link 'Calendar'
	  	click_link 'Daily Schedule'
	  	click_link 'Edit'
	  	
	  	should have_selector('title', text: 'Edit Event')
			should have_selector('h1', text: 'Edit Event')
		end
		
		it "has correct Navigation" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event, account: current_account,
					location: location,
					start_date: Time.zone.today)
	  	visit edit_event_path(event)
	
			should have_selector('li.active', text: 'Calendar')
			should have_selector('li.active', text: 'Daily Schedule')
		end
		
		it "only shows applicable fields", js: true do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event, account: current_account,
					location: location,
					start_date: Time.zone.today)
	  	visit edit_event_path(event)
	
			should_not have_selector('label', text: 'Piece')
		end
		
	  it "record with error" do
	  	log_in
			location = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event, account: current_account,
					location: location,
					start_date: Time.zone.today)
	  	visit edit_event_path(event)
	  	
	  	fill_in "Title", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-danger')
		end
	 
		it "record with valid info saves record" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event, account: current_account,
					location: location,
					start_date: Time.zone.today)
			visit edit_event_path(event)
	  	
	  	new_title = Faker::Lorem.word
			fill_in "Title", with: new_title
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Daily Schedule')
			should have_content(new_title)
		end
		
		context "with warning" do			
			it "shows warning when employee is double booked" do
			# Works in browser
				log_in
				loc1 = FactoryGirl.create(:location, account: current_account)
				loc2 = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account)
				e2 = FactoryGirl.create(:employee, account: current_account)
				e3 = FactoryGirl.create(:employee, account: current_account)
				
				r1 = FactoryGirl.create(:event, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				FactoryGirl.create(:invitation, event: r1, employee: e1)
				FactoryGirl.create(:invitation, event: r1, employee: e2)
				FactoryGirl.create(:invitation, event: r1, employee: e3)
				
				r2 = FactoryGirl.create(:event, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 60)
				FactoryGirl.create(:invitation, event: r2, employee: e1)
				
				r3 = FactoryGirl.create(:event, account: current_account,
								location: loc2,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 120)
				
				visit edit_event_path(r3)
		  	select e1.full_name, from: "Invitees"
				click_button 'Update'
		
				should have_selector('div.alert-warning', text: "people are double booked")
				should have_selector('div.alert-warning', text: e1.full_name)
				should_not have_selector('div.alert-warning', text: e2.full_name)
				should_not have_selector('div.alert-warning', text: e3.full_name)
			end
		end
	end
  
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
			it "navigates to correct day", js: true do
				log_in
				visit events_path+"/2014/1/1"
				should have_selector('h2', text: "January 1, 2014")
				
				click_link '3'
				should have_selector('h1', text: 'Daily Schedule')
				should have_selector('h2', text: "January 3, 2014")
			end
		end
	end
end
