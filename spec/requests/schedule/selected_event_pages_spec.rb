require 'spec_helper'

describe "Selected Events Pages:" do
	subject { page }
	
	context "#create" do
		before do
			log_in
  		@company_class = FactoryGirl.create(:company_class, account: current_account,
								start_date: '10/1/2014',
								start_time: '9:15 AM',
								duration: 60,
								end_date: '10/31/2014',
								monday: true, tuesday: false, wednesday: false, thursday: false, 
								friday: false, saturday: false, sunday: false)
			
			@events = @company_class.events
	  	click_link 'Calendar'
	  	click_link 'Company Classes'
	  	click_link @company_class.title
			click_link 'Dates'
		end
		
		it "returns does not display form if no events are checked" do
			click_button 'Edit Location'
			
			should have_title 'Dates'
		end
		
		describe "for Location" do
			before do
				@location = FactoryGirl.create(:location, account: current_account)
				@events.each do |event|
					check "event_ids_#{event.id}"
				end
				uncheck "event_ids_#{@events.last.id}"
				click_button 'Edit Location'
			end
			
	  	it "has correct title" do
		  	should have_title "#{@company_class.title} | Edit Location"
			  should have_selector 'h1', text: @company_class.title
				should have_selector 'h1 small', text: 'Edit Location'
			end
		
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Calendar'
				should have_selector 'li.active', text: 'Company Classes'
			end
		
			it "has correct fields on form" do
		    should have_select 'Location'
				should have_link 'Cancel', href: dates_schedule_company_class_path(@company_class)
			end
			
			it "has selected dates listed" do
				should have_content 'October 6, 2014'
				should have_content 'October 13, 2014'
				should have_content 'October 20, 2014'
			end
		
			context "with valid info" do
				before do
					select @location.name, from: "Location"
					click_button 'Update'
				end
			
				it "updates selected records" do
					should have_selector 'div.alert-success'
					should have_title 'Dates'
					
					Account.current_id = current_account.id
					@count = @events.count - 1
					should have_selector 'td', :text => @location.name, :count => @count
				end
			end
		end
		
		describe "for Instructor" do
			before do
				@instructor = FactoryGirl.create(:person, :instructor, account: current_account)
				@events.each do |event|
					check "event_ids_#{event.id}"
				end
				uncheck "event_ids_#{@events.last.id}"
				click_button 'Edit Instructor'
			end
			
	  	it "has correct title" do
		  	should have_title "#{@company_class.title} | Edit Instructor"
			  should have_selector 'h1', text: @company_class.title
				should have_selector 'h1 small', text: 'Edit Instructor'
			end
		
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Calendar'
				should have_selector 'li.active', text: 'Company Classes'
			end
		
			it "has correct fields on form" do
		    should have_select 'Instructor'
				should have_link 'Cancel', href: dates_schedule_company_class_path(@company_class)
			end
			
			it "has selected dates listed" do
				should have_content 'October 6, 2014'
				should have_content 'October 13, 2014'
				should have_content 'October 20, 2014'
			end
		
			context "with valid info" do
				before do
					select @instructor.name, from: "Instructor"
					click_button 'Update'
				end
			
				it "updates selected records" do
					should have_selector 'div.alert-success'
					should have_title 'Dates'
					
					Account.current_id = current_account.id
					@count = @events.count - 1
					should have_selector 'td', :text => @instructor.last_name, :count => @count
				end
			end
		end
		
		describe "for Musician" do
			before do
				@musician = FactoryGirl.create(:person, :musician, account: current_account)
				@events.each do |event|
					check "event_ids_#{event.id}"
				end
				uncheck "event_ids_#{@events.last.id}"
				click_button 'Edit Musician'
			end
			
	  	it "has correct title" do
		  	should have_title "#{@company_class.title} | Edit Musician"
			  should have_selector 'h1', text: @company_class.title
				should have_selector 'h1 small', text: 'Edit Musician'
			end
		
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Calendar'
				should have_selector 'li.active', text: 'Company Classes'
			end
		
			it "has correct fields on form" do
		    should have_select 'Musician'
				should have_link 'Cancel', href: dates_schedule_company_class_path(@company_class)
			end
			
			it "has selected dates listed" do
				should have_content 'October 6, 2014'
				should have_content 'October 13, 2014'
				should have_content 'October 20, 2014'
			end
		
			context "with valid info" do
				before do
					select @musician.name, from: "Musician"
					click_button 'Update'
				end
			
				it "updates selected records" do
					should have_selector 'div.alert-success'
					should have_title 'Dates'
					
					Account.current_id = current_account.id
					@count = @events.count - 1
					should have_selector 'td', :text => @musician.last_name, :count => @count
				end
			end
		end
	end
end
