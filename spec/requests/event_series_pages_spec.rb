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
end
