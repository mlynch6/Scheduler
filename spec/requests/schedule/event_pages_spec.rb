require 'spec_helper'

describe "Event Pages:" do
	subject { page }
	
  context "#index" do
		before do
  		log_in
  		click_link "Calendar"
	  	click_link "Events"
		end
		
  	it "has correct title" do	
	  	should have_title 'Events'
		  should have_selector 'h1', text: 'Events'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Events'
		end
		
		it "has correct table headers" do
			should have_selector 'th', text: Time.zone.today.strftime('%^A')
			should have_selector 'th', text: Time.zone.today.strftime('%B %-d, %Y')
			should have_selector 'th', text: "Title"
			should have_selector 'th', text: "Location"
			should have_selector 'th', text: "Instructor"
			should have_selector 'th', text: "Musician"
		end
		
		it "without records" do
			should have_selector 'td', text: 'None found'
			should_not have_selector 'div.pagination'
		end
	  
		it "lists Company Class records" do
			@date = Date.new(2014,4,3)
			company_class = FactoryGirl.create(:company_class, :daily, account: current_account,
													start_date: (@date-2.days).to_s,
													end_date: @date+2.days )
			visit schedule_events_path+"/2014/4/3"
			
			Account.current_id = current_account.id
			Event.for_day(@date).each do |event|
				should have_selector 'td', text: event.time_range
				should have_selector 'td', text: event.title
				should have_selector 'td', text: event.event_type
				should have_selector 'td', text: event.location.name if event.location
				event.instructors.each do |instructor|
					should have_selector 'td', text: instructor.last_name
				end
				event.musicians.each do |musician|
					should have_selector 'td', text: musician.last_name
				end
				
				should have_link event.title, href: schedule_company_class_path(event.schedulable)
			end
		end
		
		it "lists Costume Fitting records" do
			@date = Date.new(2014,4,3)
			fitting = FactoryGirl.create(:costume_fitting, account: current_account)
			event = FactoryGirl.create(:event, :with_location, account: current_account, schedulable: fitting, 
													start_date: @date.to_s)
			visit schedule_events_path+"/2014/4/3"
			
			Account.current_id = current_account.id
			Event.for_day(@date).each do |event|
				should have_selector 'td', text: event.time_range
				should have_selector 'td', text: event.title
				should have_selector 'td', text: event.event_type
				should have_selector 'td', text: event.location.name
				should have_link event.title, href: schedule_costume_fitting_path(event.schedulable)
	    end
		end
		
		it "lists Lecture Demo records" do
			@date = Date.new(2014,4,3)
			demo = FactoryGirl.create(:lecture_demo, account: current_account)
			event = FactoryGirl.create(:event, :with_location, account: current_account, schedulable: demo, 
													start_date: @date.to_s)
			visit schedule_events_path+"/2014/4/3"
			
			Account.current_id = current_account.id
			Event.for_day(@date).each do |event|
				should have_selector 'td', text: event.time_range
				should have_selector 'td', text: event.title
				should have_selector 'td', text: event.event_type
				should have_selector 'td', text: event.location.name
				should have_link event.title, href: schedule_lecture_demo_path(event.schedulable)
	    end
		end
		
		it "lists Rehearsal records" do
			@date = Date.new(2014,4,3)
			rehearsal = FactoryGirl.create(:rehearsal, account: current_account)
			event = FactoryGirl.create(:event, :with_location, account: current_account, schedulable: rehearsal, 
													start_date: @date.to_s)
			
			instructor1 = FactoryGirl.create(:person, :instructor, account: current_account)
			instructor2 = FactoryGirl.create(:person, :instructor, account: current_account)
			invite1 = FactoryGirl.create(:invitation, :instructor, account: current_account, event: event, person: instructor1)
			invite2 = FactoryGirl.create(:invitation, :instructor, account: current_account, event: event, person: instructor2)
			
			musician1 = FactoryGirl.create(:person, :musician, account: current_account)
			musician2 = FactoryGirl.create(:person, :musician, account: current_account)
			FactoryGirl.create(:invitation, :musician, account: current_account, event: event, person: musician1)
			FactoryGirl.create(:invitation, :musician, account: current_account, event: event, person: musician2)
			
			visit schedule_events_path+"/2014/4/3"

			Account.current_id = current_account.id
			Event.for_day(@date).each do |event|
				should have_selector 'td', text: event.time_range
				should have_selector 'td', text: event.title
				should have_selector 'td', text: event.event_type
				should have_selector 'td', text: event.location.name
				
				should have_selector 'td', text: instructor1.last_name
				should have_selector 'td', text: instructor2.last_name
				should have_selector 'td', text: musician1.last_name
				should have_selector 'td', text: musician2.last_name
				
				should have_link event.title, href: schedule_rehearsal_path(event.schedulable)
	    end
		end
		
		describe "can search" do
			before do
				@date = Date.new(2014,4,10)
				company_class = FactoryGirl.create(:company_class, :daily, account: current_account,
														start_date: (@date-6.days).to_s,
														end_date: @date+5.days )
			
				visit schedule_events_path+"/2014/4/10"
			end
			
			it "on Daily/Weekly = 'Day'" do
				select 'Day', from: "range"
				click_button 'Search'
			
				should have_selector 'th', text: 'April 10, 2014'
				
				should_not have_selector 'th', text: 'April 9, 2014'
				should_not have_selector 'th', text: 'April 11, 2014'
			end
			
			it "on Daily/Weekly = 'Week'" do
				select 'Week', from: "range"
				click_button 'Search'
			
				should have_selector 'th', text: 'April 7, 2014'
				should have_selector 'th', text: 'April 8, 2014'
				should have_selector 'th', text: 'April 9, 2014'
				should have_selector 'th', text: 'April 10, 2014'
				should have_selector 'th', text: 'April 11, 2014'
				should have_selector 'th', text: 'April 12, 2014'
				should have_selector 'th', text: 'April 13, 2014'
				
				should_not have_selector 'th', text: 'April 6, 2014'
				should_not have_selector 'th', text: 'April 14, 2014'
			end
		end
		
		it "has Daily links for Super Admin" do
			visit schedule_events_path+"/2014/4/3"
	
			should have_link 'Previous', href: schedule_events_path+"/2014/4/2"
			should have_link 'Today', href: schedule_events_path
			should have_link 'Next', href: schedule_events_path+"/2014/4/4"
		end
		
		it "has Weekly links for Super Admin" do
			visit schedule_events_path+"/2014/4/3"
			select 'Week', from: "range"
			click_button 'Search'
			
			should have_link 'Previous', href: schedule_events_path+"/2014/3/27?range=week"
			should have_link 'Today', href: schedule_events_path(range: 'week')
			should have_link 'Next', href: schedule_events_path+"/2014/4/10?range=week"
		end
		
		it "has links for Super Admin" do
			should have_link 'Warnings Report'
		end
	end
	
	context "#show" do
		before do
			log_in
			@date = Date.new(2014,4,10)
			@location = FactoryGirl.create(:location, account: current_account)
			@company_class = FactoryGirl.create(:company_class, :daily, account: current_account,
													start_date: @date.to_s,
													end_date: @date+5.days,
													duration: 60,
													location: @location )
			Account.current_id = current_account.id
			@event = @company_class.events.first
			click_link "Calendar"
			click_link "Company Classes"
			click_link @company_class.title
			click_link "Dates"
			click_link "April 10, 2014"
		end
		
  	it "has correct title" do
	  	should have_title @company_class.title
		  should have_selector 'h1', text: @company_class.title
			should have_selector 'h1 small', text: 'April 10, 2014'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Company Classes'
			should have_selector 'li.active', text: 'Overview'
		end
		
		it "displays correct data" do
			should have_content @event.title
			should have_content @location.name
			should have_content @company_class.comment
			should have_content 'April 10, 2014'
			should have_content @event.time_range
			should have_content "1 hour"
			should have_content @event.comment
		end
		
		it "has links for Super Admin" do
			should have_link 'Edit'
		end
	end
	
	context "#destroy" do
		before do
			log_in
			@date = Date.new(2014,4,10)
			@company_class = FactoryGirl.create(:company_class, :daily, account: current_account,
													start_date: @date.to_s,
													end_date: @date+5.days )
			Account.current_id = current_account.id
			@event = @company_class.events.first
			click_link "Calendar"
			click_link "Company Classes"
			click_link @company_class.title
			click_link "Dates"
			click_link "delete_#{@event.id}"
		end
		
		it "deletes the record" do
			should have_selector 'div.alert-success'
			should have_title 'Events'
			should have_selector 'th', text: 'April 10, 2014'
			
			should_not have_content @company_class.title
		end
	end
end
