require 'spec_helper'

describe "Event (non-Repeating) Pages:" do
	subject { page }

	before do
		log_in
	end
	
	context "#new" do
		it "has correct title", js: true do
			click_link 'Calendar'
			open_modal(".fc-slot61 td")	#3:15

			choose 'Event'
			click_button 'Next'
	  	
			should have_title 'New Event'
			should have_selector 'h1', text: 'New Event'
		end
		
		it "has correct Navigation" do
			visit new_event_path
	
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'New Event'
		end
		
		context "defaults correct date & time", js: true do
			it "from Daily Calendar" do
				visit events_path+"/2014/1/1"
				open_modal(".fc-slot61 td")	#3:15
			
				choose 'Event'
				click_button 'Next'
			 	
				should have_title 'New Event'
				should have_field 'Date', with: '01/01/2014'
				should have_field 'Time', with: '3:15 PM'
			end
			
			it "from Weekly Calendar" do
				visit events_path+"/2014/1/1"
				find('.fc-button-agendaWeek').click	# Week button
				open_modal(".fc-slot61 td")	#3:15
			
				choose 'Event'
				click_button 'Next'
			 	
				should have_title 'New Event'
				should have_field 'Date', with: '01/01/2014'
				should have_field 'Time', with: '3:15 PM'
			end
			
			it "from Monthly Calendar" do
				visit events_path+"/2014/1/1"
				find('.fc-button-month').click	# Month button
				open_modal(".fc-first td.fc-first")	#12/29/2013
			
				choose 'Event'
				click_button 'Next'
			 	
				should have_title 'New Event'
				should have_field 'Date', with: '12/29/2013'
				should have_field 'Time', with: ''
			end
		end
		
		it "only shows applicable fields in Overview tab", js: true do
			visit new_event_path
	
			should have_field 'Title'
			should have_select 'Location'
			should have_field 'Date'
			should have_field 'Start Time'
			should have_field 'Duration'
			should_not have_content 'Piece'	#Using Chosen
			should have_content 'Invitees'	#Using Chosen
		end
		
		it "is not repeating by default" do
			visit new_event_path
			click_link 'Repeat'
	  	
			should have_select 'Period', selected: 'Never'
		end
				
		it "has only active Locations in dropdown" do
			FactoryGirl.create(:location, account: current_account, name: 'Location A')
			FactoryGirl.create(:location_inactive, account: current_account, name: 'Location B')
			visit new_event_path
  		
			should have_select 'Location', with_options: ['Location A']
			should_not have_selector 'option', text: 'Location B'
		end
		
		it "has only active Employees in dropdown" do
			FactoryGirl.create(:employee, account: current_account, last_name: 'Parker', first_name: 'Peter')
			FactoryGirl.create(:employee_inactive, account: current_account, last_name: 'Kent', first_name: 'Clark')
			visit new_event_path
  		
			should have_select 'Invitees', with_options: ['Peter Parker']
			should_not have_selector 'option', text: 'Clark Kent'
		end
		
		context "with error" do
			it "shows error message" do
				visit new_event_path
				click_button 'Create'
		
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Event" do
				visit new_event_path
		
				expect { click_button 'Create' }.not_to change(Event, :count)
			end
			
			it "has correct start time after error is shown" do
				#tests error where start time displays full date
				visit new_event_path
				
				fill_in 'Start Time', with: "10:15AM"
				click_button 'Create'
				
				should have_selector 'div.alert-danger'
				should have_field 'Start Time', with: '10:15AM'
			end
		end

		context "with valid info", js: true do
			it "creates new Event without Invitees" do
				location = FactoryGirl.create(:location, account: current_account)
				visit new_event_path
	  		
				fill_in "Title", with: "Test Event"
				select location.name, from: "Location"
				fill_in 'Date', with: "01/31/2013"
				fill_in 'Start Time', with: "10:15AM"
				fill_in 'Duration', with: 60
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Calendar'
				
				should have_content 'Test Event'
				should have_content location.name
				should have_content '10:15 AM - 11:15 AM'
			end
		
			it "creates new Event with Invitees" do
				location = FactoryGirl.create(:location, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account)
				visit new_event_path
	  		
				fill_in "Title", with: "Test Event"
				select location.name, from: "Location"
				fill_in 'Date', with: "01/31/2013"
				fill_in 'Start Time', with: "9:15 AM"
				fill_in 'Duration', with: 60
				select_from_chosen e1.full_name, from: 'Invitees'
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Calendar'
				
				should have_content 'Test Event'
				should have_content location.name
				should have_content '9:15 AM - 10:15 AM'
				
				open_modal(".mash-event")
				click_link 'Edit'
				
				should have_content e1.full_name
			end
		end
	
		context "shows warning" do			
			it "when location is double booked" do
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
		
				should have_selector 'div.alert-warning', text: "is double booked during this time"
				should have_selector 'div.alert-warning', text: location.name
			end
			
			it "when employee is double booked" do
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
		
				should have_selector 'div.alert-warning', text: "people are double booked"
				should have_selector 'div.alert-warning', text: e1.full_name
				should_not have_selector 'div.alert-warning', text: e2.full_name
				should_not have_selector 'div.alert-warning', text: e3.full_name
			end
		end
	end
	
	context "#edit" do
		it "has correct title", js: true do
			location = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event, account: current_account,
					location: location,
					start_date: Time.zone.today)
			click_link 'Calendar'
	  	
			should have_content(event.title)
			open_modal(".mash-event")
			click_link "Edit"
	  	
			should have_title 'Edit Event'
	  		should have_selector 'h1', text: 'Edit Event'
		end
		
		it "has correct Navigation" do
			location = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event, account: current_account,
					location: location,
					start_date: Time.zone.today)
			visit edit_event_path(event)
	
			should have_selector 'li.active', text: 'Calendar'
		end
		
		it "only shows applicable fields in Overview tab", js: true do
			location = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event, account: current_account,
					location: location,
					start_date: Time.zone.today)
			visit edit_event_path(event)
	
			should have_field 'Title'
			should have_select 'Location'
			should have_field 'Date'
			should have_field 'Start Time'
			should have_field 'Duration'
			should_not have_content 'Piece'	#Using Chosen
			should have_content 'Invitees'	#Using Chosen
			
			should have_link 'Delete'
		end
		
	  describe "with error" do
			it "shows error message" do
				location = FactoryGirl.create(:location, account: current_account)
				event = FactoryGirl.create(:event, account: current_account,
						location: location,
						start_date: Time.zone.today)
				visit edit_event_path(event)
		  	
				fill_in "Title", with: ""
				click_button 'Update'
		
				should have_selector 'div.alert-danger'
			end
			
			it "has correct start time after error is shown" do
				#tests error where start time displays full date
				location = FactoryGirl.create(:location, account: current_account)
				event = FactoryGirl.create(:event, account: current_account,
						location: location,
						start_date: Time.zone.today)
				visit edit_event_path(event)
				
				fill_in "Duration", with: ""
				fill_in "Start Time", with: "10:15 AM"
				click_button 'Update'
				
				should have_selector 'div.alert-danger'
				should have_field 'Start Time', with: '10:15 AM'
			end
		end
	 
		it "record with valid info saves record", js: true do
			location = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event, account: current_account,
					location: location,
					start_date: Time.zone.today)
			visit edit_event_path(event)
	  	
			new_title = Faker::Lorem.word
			fill_in "Title", with: new_title
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Calendar'
			should have_content new_title
		end
		
		context "with warning" do			
			it "when location is double booked" do
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
		
				should have_selector 'div.alert-warning', text: "is double booked during this time"
				should have_selector 'div.alert-warning', text: location.name
			end
			
			it "shows warning when employee is double booked" do
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
		
				should have_selector 'div.alert-warning', text: "people are double booked"
				should have_selector 'div.alert-warning', text: e1.full_name
				should_not have_selector 'div.alert-warning', text: e2.full_name
				should_not have_selector 'div.alert-warning', text: e3.full_name
			end
		end
	end
  
  context "#index", js: true do
		it "has correct title & headers" do
			click_link "Calendar"
	  	
			should have_title 'Calendar'
			should have_selector 'h1', text: 'Calendar'
		  should have_selector 'h2', text: Time.zone.today.strftime('%B %-d, %Y')
		  should have_content Time.zone.today.strftime('%A')
		end
		
		it "has correct Navigation" do
			visit events_path
	
			should have_selector 'li.active', text: 'Calendar'
		end
		
		it "without records" do
			visit events_path
	  	
			should_not have_selector 'div.event'
		end
	  
	  context "lists records" do
			it "with type of Event" do
				loc = FactoryGirl.create(:location, account: current_account)
				event = FactoryGirl.create(:event,
						account: current_account,
						location: loc,
						title: 'My Event',
						start_date: Time.zone.today,
						start_time: '9:15AM')
				visit events_path
		
				should have_selector 'div', text: '9:15 AM'
				should have_selector 'div', text: 'My Event'
				should have_selector 'div', text: loc.name
			end
			
			it "with type of Company Class" do
				loc = FactoryGirl.create(:location, account: current_account)
				FactoryGirl.create(:company_class,
						account: current_account,
						location: loc,
						title: 'My Company Class',
						start_date: Time.zone.today,
						start_time: '9:15AM')
				visit events_path
		
				should have_selector 'div', text: '9:15 AM'
				should have_selector 'div', text: 'My Company Class'
				should have_selector 'div', text: loc.name
			end
			
			it "with type of Costume Fitting" do
				loc = FactoryGirl.create(:location, account: current_account)
				FactoryGirl.create(:costume_fitting,
						account: current_account,
						location: loc,
						title: 'My Costume Fitting',
						start_date: Time.zone.today,
						start_time: '9:15AM')
				visit events_path
		
				should have_selector 'div', text: '9:15 AM'
				should have_selector 'div', text: 'My Costume Fitting'
				should have_selector 'div', text: loc.name
			end
			
			it "with type of Rehearsal" do
				loc = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)	
				FactoryGirl.create(:rehearsal,
						account: current_account,
						location: loc,
						piece: piece,
						title: 'My Rehearsal',
						start_date: Time.zone.today,
						start_time: '9:15AM')
				visit events_path
		
				should have_selector 'div', text: '9:15 AM'
				should have_selector 'div', text: 'My Rehearsal'
				should have_selector 'div', text: loc.name
			end
		end
		
		describe "with date in URL" do
			it "navigates to correct day" do
				visit events_path+"/2014/1/1"
				
				should have_selector 'h2', text: "January 1, 2014"
			end
		end
	end
	
	context "#show", js: true do
		it "redirects back to #index if try to use show URL" do
			loc = FactoryGirl.create(:location, account: current_account)
			event = FactoryGirl.create(:event,
					account: current_account,
					location: loc,
					start_date: Time.zone.today)
			visit events_path(event)
			
			should have_title 'Calendar'
			should have_selector 'h1', text: 'Calendar'
		end
		
		it "displays Event details in popup window" do
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
			
			should have_selector 'small', text: 'Event'
			should have_selector 'div.dtl-label', text: 'Location'
			should have_selector 'div.dtl-label', text: 'Date'
			should have_selector 'div.dtl-label', text: 'Time'
			should have_selector 'div.dtl-label', text: 'Duration'
			should_not have_selector 'div.dtl-label', text: 'Piece'
			should have_selector 'div.dtl-label', text: 'Invitees'
			
			should have_content event.title
			should have_content event.location.name
			should have_content event.start_date
			should have_content '10:15 AM to 11:15 AM'
			should have_content event.duration
			should have_content emp.full_name
		end
		
		describe "displays Company Class" do
			it "details in popup window" do
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
				
				should have_selector 'small', text: 'Company Class'
				should have_selector 'div.dtl-label', text: 'Location'
				should have_selector 'div.dtl-label', text: 'Date'
				should have_selector 'div.dtl-label', text: 'Time'
				should have_selector 'div.dtl-label', text: 'Duration'
				should_not have_selector 'div.dtl-label', text: 'Piece'
				should have_selector 'div.dtl-label', text: 'Invitees'
				
				should have_content event.title
				should have_content event.location.name
				should have_content event.start_date
				should have_content '10:15 AM to 11:15 AM'
				should have_content event.duration
				should have_content emp.full_name
			end
			
			it "break in popup window" do
				loc = FactoryGirl.create(:location, account: current_account)
				contract = AgmaContract.find_by_account_id(current_account.id)
				contract.class_break_min = 15
				contract.save
				
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
				
				should have_selector 'div.alert-info', text: 'Break'
				should have_content '11:15 AM to 11:30 AM for 15 min'
			end
			
			it "without break if contract break is 0" do
				loc = FactoryGirl.create(:location, account: current_account)
				contract = AgmaContract.find_by_account_id(current_account.id)
				contract.class_break_min = 0
				contract.save
				
				FactoryGirl.create(:company_class,
						account: current_account,
						location: loc,
						start_date: Time.zone.today)
				visit events_path
				open_modal(".mash-event")
				
				should_not have_selector 'div.alert-info', text: 'Break'
			end
		end
		
		it "displays Costume Fitting details in popup window" do
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
			
			should have_selector 'small', text: 'Costume Fitting'
			should have_selector 'div.dtl-label', text: 'Location'
			should have_selector 'div.dtl-label', text: 'Date'
			should have_selector 'div.dtl-label', text: 'Time'
			should have_selector 'div.dtl-label', text: 'Duration'
			should_not have_selector 'div.dtl-label', text: 'Piece'
			should have_selector 'div.dtl-label', text: 'Invitees'
			
			should have_content event.title
			should have_content event.location.name
			should have_content event.start_date
			should have_content '10:15 AM to 11:15 AM'
			should have_content event.duration
			should have_content emp.full_name
		end
		
		describe "displays Rehearsal" do
			it "details in popup window" do
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
				
				should have_selector 'small', text: 'Rehearsal'
				should have_selector 'div.dtl-label', text: 'Location'
				should have_selector 'div.dtl-label', text: 'Date'
				should have_selector 'div.dtl-label', text: 'Time'
				should have_selector 'div.dtl-label', text: 'Duration'
				should have_selector 'div.dtl-label', text: 'Piece'
				should have_selector 'div.dtl-label', text: 'Invitees'
				
				should have_content event.title
				should have_content event.location.name
				should have_content event.start_date
				should have_content '10:15 AM to 11:15 AM'
				should have_content event.duration
				should have_content event.piece.name
				should have_content emp.full_name
			end
			
			it "break in popup window" do
				loc = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				break60 = FactoryGirl.create(:rehearsal_break, 
						agma_contract: current_account.agma_contract,
						duration_min: 60,
						break_min: 5)
				
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
				
				should have_selector 'div.alert-info', text: 'Break'
				should have_content '11:10 AM to 11:15 AM for 5 min'
			end
			
			it "without break if rehearsal break is 0" do
				loc = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				break60 = FactoryGirl.create(:rehearsal_break, 
						agma_contract: current_account.agma_contract,
						duration_min: 60,
						break_min: 0)
				
				FactoryGirl.create(:rehearsal,
						account: current_account,
						location: loc,
						start_date: Time.zone.today,
						duration: 60,
						piece: piece)
				visit events_path
				open_modal(".mash-event")
				
				should_not have_selector 'div.alert-info', text: 'Break'
			end
			
			it "without break if no rehearsal breaks specified" do
				loc = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				
				FactoryGirl.create(:rehearsal,
						account: current_account,
						location: loc,
						start_date: Time.zone.today,
						duration: 60,
						piece: piece)
				visit events_path
				open_modal(".mash-event")
				
				should_not have_selector 'div.alert-info', text: 'Break'
			end
		end
	end
	
	context "#destroy", js: true do
		it "deletes the record" do
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
			
			should have_link 'Delete'
			click_link 'Delete'
			page.driver.browser.switch_to.alert.accept
			
			should have_selector 'div.alert-success'
			should have_title'Calendar'
			should_not have_content event.title
		end
	end
end
