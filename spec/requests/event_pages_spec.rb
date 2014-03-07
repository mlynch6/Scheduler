require 'spec_helper'

describe "Event (non-Repeating) Pages:" do
	subject { page }
  
  context "#new" do
  	it "has correct title" do
			log_in
	  	click_link 'Calendar'
	  	click_link 'New Event'
	  	
	  	has_title?('New Event').should be_true
		  has_selector?('h1', text: 'New Event')
		end
		
		it "has correct Navigation" do
			log_in
			visit new_event_path
	
			should have_selector('li.active', text: 'Calendar')
			should have_selector('li.active', text: 'New Event')
		end
		
		it "only shows applicable fields in Overview tab", js: true do
			log_in
	  	visit new_event_path
	
			has_field?('Title').should be_true
			has_select?('Location').should be_true
			has_field?('Date').should be_true
			has_field?('Start Time').should be_true
			has_field?('Duration').should be_true
			should_not have_content('Piece')	#Using Chosen
			should have_content('Invitees')	#Using Chosen
		end
		
		it "is not repeating by default" do
			log_in
	  	visit new_event_path
	  	click_link 'Repeat'
	  	
	  	has_select? 'Period', selected: 'Never'
		end
				
		it "has only active Locations in dropdown" do
			log_in
			FactoryGirl.create(:location, account: current_account, name: 'Location A')
			FactoryGirl.create(:location_inactive, account: current_account, name: 'Location B')
			visit new_event_path
  		
			has_select? 'Location', with_options: ['Location A']
			should_not have_selector('option', text: 'Location B')
		end
		
		it "has only active Employees in dropdown" do
			log_in
			FactoryGirl.create(:employee, account: current_account, last_name: 'Parker', first_name: 'Peter')
			FactoryGirl.create(:employee_inactive, account: current_account, last_name: 'Kent', first_name: 'Clark')
			visit new_event_path
  		
			has_select? 'Invitees', with_options: ['Peter Parker']
			should_not have_selector('option', text: 'Clark Kent')
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

		context "with valid info", js: true do
			it "creates new Event without Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				visit new_event_path
	  		
		  	fill_in "Title", with: "Test Event"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2013"
		  	fill_in 'Start Time', with: "10:15AM"
		  	fill_in 'Duration', with: 60
		  	click_button 'Create'
		
				should have_selector('div.alert-success')
				has_title?('Calendar').should be_true
				
				should have_content("Test Event")
				should have_content(location.name)
				should have_content("10:15 AM - 11:15 AM")
			end
		
			it "creates new Event with Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account)
				visit new_event_path
	  		
		  	fill_in "Title", with: "Test Event"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2013"
		  	fill_in 'Start Time', with: "9:15 AM"
		  	fill_in 'Duration', with: 90
		  	select_from_chosen e1.full_name, from: 'Invitees'
				click_button 'Create'
		
				should have_selector('div.alert-success')
				has_title?('Calendar').should be_true
				
				should have_content("Test Event")
				should have_content(location.name)
				should have_content("9:15 AM - 10:45 AM")
				
				open_modal(".mash-event")
				click_link "Edit"
				
				should have_content(e1.full_name)
			end
		end
	
		context "shows warning" do			
			it "when location is double booked" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				
				event = FactoryGirl.create(:event, account: current_account,
								location: location,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				
				visit new_event_path
				fill_in "Title", with: "Test Event"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: Time.zone.today
		  	fill_in 'Start Time', with: "11AM"
		  	fill_in 'Duration', with: 120
				click_button 'Create'
		
				should have_selector('div.alert-warning', text: "is double booked during this time")
				should have_selector('div.alert-warning', text: location.name)
			end
			
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
		it "has correct title", js: true do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event, account: current_account,
					location: location,
					start_date: Time.zone.today)
	  	click_link 'Calendar'
	  	
	  	should have_content(event.title)
			open_modal(".mash-event")
			click_link "Edit"
	  	
	  	has_title?('Edit Event').should be_true
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
		end
		
		it "only shows applicable fields in Overview tab", js: true do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event, account: current_account,
					location: location,
					start_date: Time.zone.today)
	  	visit edit_event_path(event)
	
			has_field?('Title').should be_true
			has_select?('Location').should be_true
			has_field?('Date').should be_true
			has_field?('Start Time').should be_true
			has_field?('Duration').should be_true
			should_not have_content('Piece')	#Using Chosen
			should have_content('Invitees')	#Using Chosen
			
			has_link?('Delete').should be_true
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
	 
		it "record with valid info saves record", js: true do
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
			has_title?('Calendar').should be_true
			should have_content(new_title)
		end
		
		context "with warning" do			
			it "when location is double booked" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				
				event = FactoryGirl.create(:event, account: current_account,
								location: location,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
								
				e2 = FactoryGirl.create(:event, account: current_account,
								location: location,
								start_date: Time.zone.today,
								start_time: "1 PM",
								duration: 60)
				
				visit edit_event_path(e2)
		  	fill_in 'Start Time', with: "11:30 AM"
				click_button 'Update'
		
				should have_selector('div.alert-warning', text: "is double booked during this time")
				should have_selector('div.alert-warning', text: location.name)
			end
			
			it "shows warning when employee is double booked" do
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
  
  context "#index", js: true do
  	it "has correct title & headers" do
			log_in
			click_link "Calendar"
	  	
	  	has_title?('Calendar').should be_true
	  	should have_selector('h1', text: 'Calendar')
		  should have_selector('h2', text: Time.zone.today.strftime('%B %-d, %Y'))
		  should have_content(Time.zone.today.strftime('%A'))
		end
		
		it "has correct Navigation" do
			log_in
			visit events_path
	
			should have_selector('li.active', text: 'Calendar')
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
		
		describe "with date in URL" do
			it "navigates to correct day" do
				log_in
				visit events_path+"/2014/1/1"
				
				should have_selector('h2', text: "January 1, 2014")
			end
		end
	end
	
	context "#show", js: true do
		it "redirects back to #index if try to use show URL" do
			log_in
			loc = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event,
					account: current_account,
					location: loc,
					start_date: Time.zone.today)
			visit events_path(event)
			
			has_title?('Calendar').should be_true
			should have_selector('h1', text: 'Calendar')
		end
		
		it "displays Event details in popup window" do
			pending "seems to wok in GUI, but Time is off in test by 1 hr"
			log_in
			loc = FactoryGirl.create(:location, account: current_account)
			emp = FactoryGirl.create(:employee, account: current_account)
			event = FactoryGirl.create(:event,
					account: current_account,
					location: loc,
					start_date: Time.zone.today,
					start_time: '10:15 AM',
					duration: 60)
			FactoryGirl.create(:invitation, event: event, employee: emp)
			visit events_path
			open_modal(".mash-event")
			
			should have_selector('small', text: 'Event')
			should have_selector('div.dtl-label', text: 'Location')
			should have_selector('div.dtl-label', text: 'Date')
			should have_selector('div.dtl-label', text: 'Time')
			should have_selector('div.dtl-label', text: 'Duration')
			should_not have_selector('div.dtl-label', text: 'Piece')
			should have_selector('div.dtl-label', text: 'Invitees')
			
			should have_content(event.title)
			should have_content(event.location.name)
			should have_content(event.start_date)
			should have_content('10:15 AM to 11:15 AM')
			should have_content(event.duration)
			should have_content(emp.full_name)
		end
		
		describe "displays Company Class" do
			it "details in popup window" do
				pending "seems to wok in GUI, but Time is off in test by 1 hr"
				log_in
				loc = FactoryGirl.create(:location, account: current_account)
				emp = FactoryGirl.create(:employee, account: current_account)
				event = FactoryGirl.create(:company_class,
						account: current_account,
						location: loc,
						start_date: Time.zone.today,
						start_time: '10:15am',
						duration: 60)
				FactoryGirl.create(:invitation, event: event, employee: emp)
				visit events_path
				open_modal(".mash-event")
				
				should have_selector('small', text: 'Company Class')
				should have_selector('div.dtl-label', text: 'Location')
				should have_selector('div.dtl-label', text: 'Date')
				should have_selector('div.dtl-label', text: 'Time')
				should have_selector('div.dtl-label', text: 'Duration')
				should_not have_selector('div.dtl-label', text: 'Piece')
				should have_selector('div.dtl-label', text: 'Invitees')
				
				should have_content(event.title)
				should have_content(event.location.name)
				should have_content(event.start_date)
				should have_content('10:15 AM to 11:15 AM')
				should have_content(event.duration)
				should have_content(emp.full_name)
			end
			
			it "break in popup window" do
				pending "seems to wok in GUI, but Time is off in test by 1 hr"
				log_in
				loc = FactoryGirl.create(:location, account: current_account)
				profile = AgmaProfile.find_by_account_id(current_account.id)
				profile.class_break_min = 15
				profile.save
				
				emp = FactoryGirl.create(:employee, account: current_account)
				event = FactoryGirl.create(:company_class,
						account: current_account,
						location: loc,
						start_date: Time.zone.today,
						start_time: '10:15am',
						duration: 60)
				FactoryGirl.create(:invitation, event: event, employee: emp)
				visit events_path
				open_modal(".mash-event")
				
				should have_selector('div.alert-info', text: 'Break')
				should have_content('11:15 AM to 11:30 AM for 15 min')
			end
			
			it "without break if contract break is 0" do
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
				open_modal(".mash-event")
				
				should_not have_selector('div.alert-info', text: 'Break')
			end
		end
		
		it "displays Costume Fitting details in popup window" do
			pending "seems to wok in GUI, but Time is off in test by 1 hr"
			log_in
			loc = FactoryGirl.create(:location, account: current_account)
			emp = FactoryGirl.create(:employee, account: current_account)
			event = FactoryGirl.create(:costume_fitting,
					account: current_account,
					location: loc,
					start_date: Time.zone.today,
					start_time: '10:15am',
					duration: 60)
			FactoryGirl.create(:invitation, event: event, employee: emp)
			visit events_path
			open_modal(".mash-event")
			
			should have_selector('small', text: 'Costume Fitting')
			should have_selector('div.dtl-label', text: 'Location')
			should have_selector('div.dtl-label', text: 'Date')
			should have_selector('div.dtl-label', text: 'Time')
			should have_selector('div.dtl-label', text: 'Duration')
			should_not have_selector('div.dtl-label', text: 'Piece')
			should have_selector('div.dtl-label', text: 'Invitees')
			
			should have_content(event.title)
			should have_content(event.location.name)
			should have_content(event.start_date)
			should have_content('10:15 AM to 11:15 AM')
			should have_content(event.duration)
			should have_content(emp.full_name)
		end
		
		describe "displays Rehearsal" do
			it "details in popup window" do
				pending "seems to wok in GUI, but Time is off in test by 1 hr"
				log_in
				loc = FactoryGirl.create(:location, account: current_account)
				emp = FactoryGirl.create(:employee, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				event = FactoryGirl.create(:rehearsal,
						account: current_account,
						location: loc,
						start_date: Time.zone.today,
						start_time: '10:15am',
						duration: 60,
						piece: piece)
				FactoryGirl.create(:invitation, event: event, employee: emp)
				visit events_path
				open_modal(".mash-event")
				
				should have_selector('small', text: 'Rehearsal')
				should have_selector('div.dtl-label', text: 'Location')
				should have_selector('div.dtl-label', text: 'Date')
				should have_selector('div.dtl-label', text: 'Time')
				should have_selector('div.dtl-label', text: 'Duration')
				should have_selector('div.dtl-label', text: 'Piece')
				should have_selector('div.dtl-label', text: 'Invitees')
				
				should have_content(event.title)
				should have_content(event.location.name)
				should have_content(event.start_date)
				should have_content('10:15 AM to 11:15 AM')
				should have_content(event.duration)
				should have_content(event.piece.name)
				should have_content(emp.full_name)
			end
			
			it "break in popup window" do
				pending "seems to wok in GUI, but Time is off in test by 1 hr"
				log_in
				loc = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				profile = AgmaProfile.find_by_account_id(current_account.id)
				profile.rehearsal_break_min_per_hr = 5
				profile.save
				
				emp = FactoryGirl.create(:employee, account: current_account)
				event = FactoryGirl.create(:rehearsal,
						account: current_account,
						location: loc,
						start_date: Time.zone.today,
						start_time: '10:15am',
						duration: 60,
						piece: piece)
				FactoryGirl.create(:invitation, event: event, employee: emp)
				visit events_path
				open_modal(".mash-event")
				
				should have_selector('div.alert-info', text: 'Break')
				should have_content('11:10 AM to 11:15 AM for 5 min')
			end
			
			it "without break if contract break is 0" do
				log_in
				loc = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				profile = AgmaProfile.find_by_account_id(current_account.id)
				profile.rehearsal_break_min_per_hr = 0
				profile.save
				
				FactoryGirl.create(:rehearsal,
						account: current_account,
						location: loc,
						start_date: Time.zone.today,
						piece: piece)
				visit events_path
				open_modal(".mash-event")
				
				should_not have_selector('div.alert-info', text: 'Break')
			end
		end
	end
	
	context "#destroy", js: true do
		it "deletes the record" do
	  	log_in
			location = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event, account: current_account,
								location: location,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
			visit events_path
			
			should have_content(event.title)
			open_modal(".mash-event")
			click_link "Edit"
			
			should have_link('Delete')
			click_link 'Delete'
			page.driver.browser.switch_to.alert.accept
			
			should have_selector('div.alert-success')
			has_title?('Calendar').should be_true
			should_not have_content(event.title)
		end
	end
end
