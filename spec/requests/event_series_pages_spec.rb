require 'spec_helper'

describe "Event Series Pages:" do
	subject { page }
  
  context "#new" do
  	it "has correct title" do
			log_in
	  	click_link 'Calendar'
	  	visit new_event_path
	  	
	  	should have_selector('title', text: 'New Event')
		  should have_selector('h1', text: 'New Event')
		end
		
		it "only shows applicable fields for Repeat tab", js: true do
			log_in
	  	visit new_event_path
	  	
	  	click_link "Repeat"
	  	should_not have_selector('label', text: 'End On')
	  	
			select "Daily", from: 'Period'
			should have_selector('label', text: 'End On')
			
			select "Never", from: 'Period'
			should_not have_selector('label', text: 'End On')
			
			select "Monthly", from: 'Period'
			should have_selector('label', text: 'End On')
			
			select "Never", from: 'Period'
			should_not have_selector('label', text: 'End On')
			
			select "Yearly", from: 'Period'
			should have_selector('label', text: 'End On')
			
			select "Never", from: 'Period'
			should_not have_selector('label', text: 'End On')
		end
		
		context "with error" do
			before do
				log_in
				location = FactoryGirl.create(:location, account: current_account, name: 'Loc1')
				visit new_event_path
				
		  	fill_in "Title", with: "Repeating Event"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2013"
		  	fill_in 'Start Time', with: "10AM"
		  	fill_in 'Duration', with: 60
				click_link 'Repeat'
	  		select 'Daily', from: 'Period'
	  	end
	  	
			it "shows error message" do
				fill_in 'End On', with: "01/1/2013"
				click_button 'Create'
		
				should have_selector('div.alert-danger')
				should have_content('End Date must be after the Start Date')
			end
			
			it "doesn't create EventSeries" do
				expect { click_button 'Create' }.not_to change(EventSeries, :count)
			end
			
			it "doesn't create Event" do
				expect { click_button 'Create' }.not_to change(Event, :count)
			end
		end

		context "with valid info" do
			before do
				log_in
				location = FactoryGirl.create(:location, account: current_account, name: 'Loc1')
				emp = FactoryGirl.create(:employee, account: current_account, first_name: 'Peter', last_name: 'Parker')
				visit new_event_path
				
		  	fill_in "Title", with: "Repeating Event"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/01/2013"
		  	fill_in 'Start Time', with: "10AM"
		  	fill_in 'Duration', with: 60
		  	
		  	click_link 'Repeat'
	  		select 'Daily', from: 'Period'
				fill_in 'End On', with: "01/05/2013"
		  	click_button 'Create'
	  	end
	  	
			it "creates Series with multiple Events", js: true do
				should have_selector('div.alert-success')
				
				(Date.new(2013,1,1)..Date.new(2013,1,5)).each do |dt|
					click_link dt.strftime('%-d')
					should have_content(dt.strftime('%A, %B %-d, %Y'))
					should have_content("Repeating Event")
					should have_content('Loc1')
					should have_content("10:00 AM to 11:00 AM")
				end
			end
		end
		
		context "with warnings" do
	  	it "shows warning when location is booked" do
				pending
	  		log_in
				location = FactoryGirl.create(:location, account: current_account, name: 'Loc1')
				event = FactoryGirl.create(:event, account: current_account,
										location: location,
										start_date: Date.new(2013, 1, 2),
										start_time: "10 AM",
										duration: 90)
				visit new_event_path
				
		  	fill_in "Title", with: "Repeating Event"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/01/2013"
		  	fill_in 'Start Time', with: "10AM"
		  	fill_in 'Duration', with: 60
		  	click_link 'Repeat'
	  		select 'Daily', from: 'Period'
				fill_in 'End On', with: "01/05/2013"
				click_button 'Create'
		
				should have_selector('div.alert-warning', text: "is double booked during this time")
				should have_selector('div.alert-warning', text: location.name)
			end
			
			it "shows warning when employee is double booked" do
				pending
			end
		end
	end
	
	context "#edit" do
		before do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			visit new_event_path
				
	  	fill_in "Title", with: "Repeating Event"
	  	select location.name, from: "Location"
	  	fill_in 'Date', with: "01/01/2013"
	  	fill_in 'Start Time', with: "10AM"
	  	fill_in 'Duration', with: 60
	  	
	  	click_link 'Repeat'
  		select 'Daily', from: 'Period'
			fill_in 'End On', with: "01/05/2013"
	  	click_button 'Create'
		end
		
		it "has correct title" do
	  	click_link 'Edit'
	  	
	  	should have_selector('title', text: 'Edit Event')
			should have_selector('h1', text: 'Edit Event')
		end
		
		it "has correct Navigation" do
	  	click_link 'Edit'
	
			should have_selector('li.active', text: 'Calendar')
			should have_selector('li.active', text: 'Daily Schedule')
		end
		
#		it "only shows applicable fields", js: true do
#			event = Event.last
#			find("#event_#{event.id}").click
#			wait_until { find(".modal-dialog").visible? }
#			click_link 'Edit'
#			
#			should_not have_selector('label', text: 'Piece')
#		end
#		
#	  it "record with error" do
#	  	log_in
#			location = FactoryGirl.create(:location, account: current_account)
#			event = FactoryGirl.create(:event, account: current_account,
#					location: location,
#					start_date: Time.zone.today)
#	  	visit edit_event_path(event)
#	  	
#	  	fill_in "Title", with: ""
#	  	click_button 'Update'
#	
#			should have_selector('div.alert-danger')
#		end
#	 
#		it "record with valid info saves record" do
#			log_in
#			location = FactoryGirl.create(:location, account: current_account)
#			event = FactoryGirl.create(:event, account: current_account,
#					location: location,
#					start_date: Time.zone.today)
#			visit edit_event_path(event)
#	  	
#	  	new_title = Faker::Lorem.word
#			fill_in "Title", with: new_title
#			click_button 'Update'
#	
#			should have_selector('div.alert-success')
#			should have_selector('title', text: 'Daily Schedule')
#			should have_content(new_title)
#		end
#		
#		context "with warning" do			
#			it "when location is double booked" do
#				log_in
#				location = FactoryGirl.create(:location, account: current_account)
#				
#				event = FactoryGirl.create(:event, account: current_account,
#								location: location,
#								start_date: Time.zone.today,
#								start_time: "11 AM",
#								duration: 60)
#								
#				e2 = FactoryGirl.create(:event, account: current_account,
#								location: location,
#								start_date: Time.zone.today,
#								start_time: "1 PM",
#								duration: 60)
#				
#				visit edit_event_path(e2)
#		  	fill_in 'Start Time', with: "11:30 AM"
#				click_button 'Update'
#		
#				should have_selector('div.alert-warning', text: "is double booked during this time")
#				should have_selector('div.alert-warning', text: location.name)
#			end
#			
#			it "shows warning when employee is double booked" do
#				log_in
#				loc1 = FactoryGirl.create(:location, account: current_account)
#				loc2 = FactoryGirl.create(:location, account: current_account)
#				piece = FactoryGirl.create(:piece, account: current_account)
#				e1 = FactoryGirl.create(:employee, account: current_account)
#				e2 = FactoryGirl.create(:employee, account: current_account)
#				e3 = FactoryGirl.create(:employee, account: current_account)
#				
#				r1 = FactoryGirl.create(:event, account: current_account,
#								location: loc1,
#								start_date: Time.zone.today,
#								start_time: "11 AM",
#								duration: 60)
#				FactoryGirl.create(:invitation, event: r1, employee: e1)
#				FactoryGirl.create(:invitation, event: r1, employee: e2)
#				FactoryGirl.create(:invitation, event: r1, employee: e3)
#				
#				r2 = FactoryGirl.create(:event, account: current_account,
#								location: loc1,
#								start_date: Time.zone.today,
#								start_time: "12 PM",
#								duration: 60)
#				FactoryGirl.create(:invitation, event: r2, employee: e1)
#				
#				r3 = FactoryGirl.create(:event, account: current_account,
#								location: loc2,
#								start_date: Time.zone.today,
#								start_time: "11 AM",
#								duration: 120)
#				
#				visit edit_event_path(r3)
#		  	select e1.full_name, from: "Invitees"
#				click_button 'Update'
#		
#				should have_selector('div.alert-warning', text: "people are double booked")
#				should have_selector('div.alert-warning', text: e1.full_name)
#				should_not have_selector('div.alert-warning', text: e2.full_name)
#				should_not have_selector('div.alert-warning', text: e3.full_name)
#			end
#		end
	end
	
	context "#destroy", js: true do
		describe "when 'Delete Only This Event' is selected" do
			it "deletes the event" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				Account.current_id = current_account.id
				series = FactoryGirl.create(:event_series, 
									title: 'My Repeating',
									location_id: location.id,
									start_date: Date.new(2014,1,1),
									start_time: "11 AM",
									duration: 60,
									period: 'Daily',
									end_date: Date.new(2014,1,5))
				e2 = series.events.offset(1).first	#01/02/2014
				visit events_path+'/2014/1/2'
				
				should have_content(e2.title)
				find("#event_#{e2.id}").click
				wait_until { find(".modal-dialog").visible? }
				click_link "Edit"
				
				click_button 'Delete'
				wait_until { find(".modal-dialog").visible? }
				
				should have_link('Delete All Future Events')
				should have_link('Delete Only This Event')
				
				click_link('Delete Only This Event')
				
				should have_selector('div.alert-success')
				should have_selector('h2', text: 'January 2, 2014')
				should_not have_content('My Repeating')
			end
			
			it "does not delete the other repeating events" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				Account.current_id = current_account.id
				series = FactoryGirl.create(:event_series, 
									title: 'My Repeating',
									location_id: location.id,
									start_date: Date.new(2014,1,1),
									start_time: "11 AM",
									duration: 60,
									period: 'Daily',
									end_date: Date.new(2014,1,5))
				e2 = series.events.offset(1).first	#01/02/2014
				visit events_path+'/2014/1/2'
				
				should have_content(e2.title)
				find("#event_#{e2.id}").click
				wait_until { find(".modal-dialog").visible? }
				click_link "Edit"
				
				click_button 'Delete'
				wait_until { find(".modal-dialog").visible? }
				
				should have_link('Delete All Future Events')
				should have_link('Delete Only This Event')
				
				click_link('Delete Only This Event')
				should have_selector('div.alert-success')
				
				click_link '1'
				should have_selector('h2', text: 'January 1, 2014')
				should have_content('My Repeating')
				
				click_link '3'
				should have_selector('h2', text: 'January 3, 2014')
				should have_content('My Repeating')
				
				click_link '4'
				should have_selector('h2', text: 'January 4, 2014')
				should have_content('My Repeating')
				
				click_link '5'
				should have_selector('h2', text: 'January 5, 2014')
				should have_content('My Repeating')
			end
			
			it "updates the series end_date when the last event in series is deleted" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				Account.current_id = current_account.id
				series = FactoryGirl.create(:event_series, 
									title: 'My Repeating',
									location_id: location.id,
									start_date: Date.new(2014,1,1),
									start_time: "11 AM",
									duration: 60,
									period: 'Daily',
									end_date: Date.new(2014,1,5))
				e5 = series.events.last	#01/05/2014
				visit events_path+'/2014/1/5'
				
				should have_content(e5.title)
				find("#event_#{e5.id}").click
				wait_until { find(".modal-dialog").visible? }
				click_link "Edit"
				
				click_button 'Delete'
				wait_until { find(".modal-dialog").visible? }
				
				should have_link('Delete All Future Events')
				should have_link('Delete Only This Event')
				
				click_link('Delete Only This Event')
				should have_selector('div.alert-success')
				
		  	click_link '1'
				should have_selector('h2', text: 'January 1, 2014')
				e1 = series.events.first	#01/01/2014
				find("#event_#{e1.id}").click
				wait_until { find(".modal-dialog").visible? }
				
				should have_content('01/04/2014')
			end
		end
		
		describe "when 'Delete All' is selected" do
			it "deletes the all events in the series" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				Account.current_id = current_account.id
				series = FactoryGirl.create(:event_series, 
									title: 'My Repeating',
									location_id: location.id,
									start_date: Date.new(2014,1,1),
									start_time: "11 AM",
									duration: 60,
									period: 'Daily',
									end_date: Date.new(2014,1,5))
				e1 = series.events.first
				visit events_path+'/2014/1/1'
				
				should have_content(e1.title)
				find("#event_#{e1.id}").click
				wait_until { find(".modal-dialog").visible? }
				click_link "Edit"
				
				click_button 'Delete'
				wait_until { find(".modal-dialog").visible? }
				
				click_link('Delete All')
				should have_selector('div.alert-success')
				
				click_link '1'
				should have_selector('h2', text: 'January 1, 2014')
				should_not have_content('My Repeating')
				
				click_link '2'
				should have_selector('h2', text: 'January 2, 2014')
				should_not have_content('My Repeating')
				
				click_link '3'
				should have_selector('h2', text: 'January 3, 2014')
				should_not have_content('My Repeating')
				
				click_link '4'
				should have_selector('h2', text: 'January 4, 2014')
				should_not have_content('My Repeating')
				
				click_link '5'
				should have_selector('h2', text: 'January 5, 2014')
				should_not have_content('My Repeating')
			end
		end
		
		describe "when 'Delete All Future Events' is selected" do
			it "deletes the current event & repeating events in future" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				Account.current_id = current_account.id
				series = FactoryGirl.create(:event_series, 
									title: 'My Repeating',
									location_id: location.id,
									start_date: Date.new(2014,1,1),
									start_time: "11 AM",
									duration: 60,
									period: 'Daily',
									end_date: Date.new(2014,1,5))
				e3 = series.events.offset(2).first
				visit events_path+'/2014/1/3'
				
				should have_content(e3.title)
				find("#event_#{e3.id}").click
				wait_until { find(".modal-dialog").visible? }
				click_link "Edit"
				
				click_button 'Delete'
				wait_until { find(".modal-dialog").visible? }
				
				click_link('Delete All Future Events')
				should have_selector('div.alert-success')
				
				click_link '1'
				should have_selector('h2', text: 'January 1, 2014')
				should have_content('My Repeating')
				
				click_link '2'
				should have_selector('h2', text: 'January 2, 2014')
				should have_content('My Repeating')
				
				click_link '3'
				should have_selector('h2', text: 'January 3, 2014')
				should_not have_content('My Repeating')
				
				click_link '4'
				should have_selector('h2', text: 'January 4, 2014')
				should_not have_content('My Repeating')
				
				click_link '5'
				should have_selector('h2', text: 'January 5, 2014')
				should_not have_content('My Repeating')
			end
			
			it "updates the series end_date" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				Account.current_id = current_account.id
				series = FactoryGirl.create(:event_series, 
									title: 'My Repeating',
									location_id: location.id,
									start_date: Date.new(2014,1,1),
									start_time: "11 AM",
									duration: 60,
									period: 'Daily',
									end_date: Date.new(2014,1,5))
				e1 = series.events.first
				e3 = series.events.offset(2).first
				visit events_path+'/2014/1/3'
				
				should have_content(e3.title)
				find("#event_#{e3.id}").click
				wait_until { find(".modal-dialog").visible? }
				click_link "Edit"
				
				click_button 'Delete'
				wait_until { find(".modal-dialog").visible? }
				
				click_link('Delete All Future Events')
				should have_selector('div.alert-success')
				
				click_link '1'
				should have_selector('h2', text: 'January 1, 2014')
				should have_content('My Repeating')
				find("#event_#{e1.id}").click
				wait_until { find(".modal-dialog").visible? }
				should have_content('01/02/2014')
			end
		end
	end
end
