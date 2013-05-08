require 'spec_helper'

describe "Event Pages:" do
	subject { page }
  
  context "#index" do
  	it "has correct title & headers" do
			log_in
	  	click_link "Daily Schedule"
	  	
	  	should have_selector('title', text: 'Daily Schedule')
		 	
		  should have_selector('h2', text: Time.zone.today.strftime('%A, %B %-d, %Y'))
		  should have_content(Time.zone.today.strftime('%A'))
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
					start_date: Time.zone.today,
					start_time: "10AM",
					end_time: "11AM")
			visit events_path
	
			Event.for_daily_calendar(Time.zone.today).each do |rehearsal|
				should have_selector('div', text: rehearsal.title)
				should have_selector('div', text: rehearsal.location.name)
				should have_content(event.start_at.to_s(:hr12))
				should have_content(event.end_at.to_s(:hr12))
				should have_selector('div', text: rehearsal.piece.name)
				
				should have_link('View', href: rehearsal_path)
				should have_link('Edit', href: edit_rehearsal_path)
	    end
		end
		
		it "shows Rehearsal details in popup window"
		
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
				
				should have_link('View', href: company_class_path)
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
		
		it "shows Company Class details in popup window"
		
		it "doesn't have links for Employee" do
			log_in_employee
			location = FactoryGirl.create(:location, account: current_account)
			FactoryGirl.create(:event, account: current_account, location: location)
			visit events_path
	
			should_not have_link('New Company Class')
			should_not have_link('New Rehearsal')
		end
		
		it "has links for Administrator" do
			log_in_admin
			location = FactoryGirl.create(:location, account: current_account)
			FactoryGirl.create(:event, account: current_account, location: location)
			visit events_path
	
			should have_link('New Company Class')
			should have_link('New Rehearsal')
		end
		
	end
end
