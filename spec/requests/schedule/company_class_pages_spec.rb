require 'spec_helper'

describe "Company Class Pages:" do
	subject { page }
	
  context "#index" do
		before do
  		log_in
  		click_link "Calendar"
	  	click_link "Company Classes"
		end
		
  	it "has correct title" do	
	  	should have_title 'Company Classes'
		  should have_selector 'h1', text: 'Company Classes'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Company Classes'
		end
		
		it "has correct table headers" do
			should have_selector 'th', text: "Title"
			should have_selector 'th', text: "Date/Time"
			should have_selector 'th', text: "Days of Week"
			should have_selector 'th', text: "Location"
		end
		
		it "without records" do
			should have_selector 'td', text: 'None found'
			should_not have_selector 'div.pagination'
		end
	  
		it "lists records" do
			4.times { company_class = FactoryGirl.create(:company_class, account: current_account) }
			visit schedule_company_classes_path(per_page: 3)
			
			should have_selector 'div.pagination'
			CompanyClass.paginate(page: 1, per_page: 3).each do |company_class|
				should have_selector 'td', text: company_class.title
				should have_selector 'td', text: company_class.date_range
				should have_selector 'td', text: company_class.time_range
				should have_selector 'td', text: company_class.days_of_week
				should have_selector 'td', text: company_class.location.name
				
				should have_link company_class.title, href: schedule_company_class_path(company_class)
				should have_link 'Delete', href: schedule_company_class_path(company_class)
	    end
		end
		
		describe "can search" do
			before do
				4.times { company_class = FactoryGirl.create(:company_class, account: current_account) }
				@season = FactoryGirl.create(:season, account: current_account)
				@location = FactoryGirl.create(:location, account: current_account)
				@rhino = FactoryGirl.create(:company_class, account: current_account, title: 'My Rhino Class', season: @season, location: @location)
				visit schedule_company_classes_path
			end
			
			it "on Title" do
				fill_in "Title", with: 'Rhino'
				click_button 'Search'
			
				should have_selector 'tr', count: 2
				should have_selector 'td', text: @rhino.title
			end
			
			it "on Season" do	
				select @season.name, from: 'season'
				click_button 'Search'
			
				should have_selector 'tr', count: 2
				should have_selector 'td', text: @rhino.title
			end
		
			it "on Location" do
				select @location.name, from: 'loc'
				click_button 'Search'
			
				should have_selector 'tr', count: 2
				should have_selector 'td', text: @rhino.title
			end
		end
		
		it "has links for Super Admin" do
			company_class = FactoryGirl.create(:company_class, account: current_account)
			visit schedule_company_classes_path
	
			should have_link 'Add Company Class'
			should have_link company_class.title
			should have_link 'Delete'
		end
	end
	
  context "#new" do
		before do
			log_in
			click_link 'Calendar'
			click_link 'Company Classes'
			click_link 'Add Company Class'
		end
		
		it "has correct title" do
			should have_title 'Add Company Class'
		  should have_selector 'h1', text: 'Company Classes'
			should have_selector 'h1 small', text: 'Add'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Company Classes'
		end
		
		it "has correct fields on form" do
	    should have_field 'Title'
			should have_field 'Location'
			should have_field 'Season'
			should have_field 'Start Date'
			should have_field 'Start Time'
			should have_field 'Duration'
			should have_field 'End Date'
			should have_unchecked_field 'Mon'
			should have_unchecked_field 'Tues'
			should have_unchecked_field 'Wed'
			should have_unchecked_field 'Thur'
			should have_unchecked_field 'Fri'
			should have_unchecked_field 'Sat'
			should have_unchecked_field 'Sun'
			should have_field 'Description'
			should have_link 'Cancel', href: schedule_company_classes_path
		end
		
		context "with error" do
			it "shows error message" do
				click_button 'Schedule'
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Lecture Demo" do
				expect { click_button 'Schedule' }.not_to change(CompanyClass, :count)
			end
			
			it "doesn't create Event" do
				expect { click_button 'Schedule' }.not_to change(Event, :count)
			end
		end
		
		context "with valid info" do
			before do
				@location = FactoryGirl.create(:location, account: current_account)
				@season = FactoryGirl.create(:season, account: current_account)
				visit new_schedule_company_class_path
	  		
				fill_in "Title", with: "Daily Company Class"
				select @location.name, from: "Location"
				select @season.name, from: 'Season'
				fill_in 'Start Date', with: "01/31/2013"
				fill_in 'Start Time', with: "10:15AM"
				fill_in 'Duration', with: 60
				fill_in 'End Date', with: "03/01/2013"
				check 'Mon'
				check 'Tues'
				check 'Wed'
				check 'Thur'
				check 'Fri'
				uncheck 'Sat'
				uncheck 'Sun'
				click_button 'Schedule'
			end
			
			it "creates new Company Class" do
				should have_selector 'div.alert-success'
				should have_title 'Company Classes'
				should have_content 'Daily Company Class'
				should have_content '01/31/2013'
				should have_content '10:15 AM to 11:15 AM'
				should have_content @location.name
			end
		end
	end
	
	context "#edit" do
		before do
			log_in
			@company_class = FactoryGirl.create(:company_class, account: current_account)
			click_link 'Calendar'
			click_link 'Company Classes'
	  	click_link @company_class.title
			click_link 'Edit'
		end
		
		it "has correct title" do	
	  	should have_title 'Edit Company Class'
			should have_selector 'h1', text: 'Company Classes'
			should have_selector 'h1 small', text: 'Edit'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Company Classes'
		end
		
		it "has correct fields on form" do
	    should have_field 'Title'
			should have_field 'Description'
			should have_link 'Cancel', href: schedule_company_class_path(@company_class)
		end
		
	  it "record with error" do
	  	fill_in "Title", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "record with valid info is saved" do
			new_title = Faker::Lorem.word
			fill_in "Title", with: new_title
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Company Classes'
			should have_content new_title
		end
	end
	
	context "#destroy" do
		before do
			log_in
			@company_class = FactoryGirl.create(:company_class, account: current_account)
			visit schedule_company_classes_path
			click_link "delete_#{@company_class.id}"
		end
		
		it "deletes the record" do
			should have_selector 'div.alert-success'
			should have_title 'Company Classes'
			
			should_not have_content @company_class.title
		end
	end
	
	context "#show" do
		before do
  		log_in
  		@company_class = FactoryGirl.create(:company_class, account: current_account,
								start_date: '10/1/2014',
								start_time: '9:15 AM',
								duration: 60,
								end_date: '10/15/2014')
			
	  	click_link 'Calendar'
	  	click_link 'Company Classes'
	  	click_link @company_class.title
		end
		
  	it "has correct title" do
	  	should have_title @company_class.title
		  should have_selector 'h1', text: @company_class.title
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Company Classes'
			should have_selector 'li.active', text: 'Overview'
		end
		
		it "displays correct data" do
			should have_content @company_class.title
			should have_content @company_class.location.name
			should have_content @company_class.comment
			should have_content '10/01/2014 to 10/15/2014'
			should have_content '9:15 AM to 10:15 AM'
			should have_content "#{@company_class.duration} minutes"
			should have_content @company_class.days_of_week
		end
		
		it "has links for Super Admin" do
			should have_link 'Edit'
		end
	end
	
  context "#dates" do
		before do
			log_in
  		@company_class = FactoryGirl.create(:company_class, account: current_account,
								start_date: '10/1/2014',
								start_time: '9:15 AM',
								duration: 60,
								end_date: '10/31/2014',
								monday: true, tuesday: false, wednesday: false, thursday: false, 
								friday: false, saturday: false, sunday: false)
	  	click_link 'Calendar'
	  	click_link 'Company Classes'
	  	click_link @company_class.title
			click_link 'Dates'
		end
		
  	it "has correct title" do	
	  	should have_title @company_class.title
		  should have_selector 'h1', text: @company_class.title
			should have_selector 'h1 small', text: 'Dates'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Company Classes'
		end
		
		it "has correct table headers" do
			should have_selector 'th', text: "Date"
			should have_selector 'th', text: "Time"
			should have_selector 'th', text: "Duration"
			should have_selector 'th', text: "Location"
		end
		
		it "without records" do
			Account.current_id = current_account.id
			@company_class.events.destroy_all
			click_link 'Dates'
			should have_selector 'td', text: 'None found'
		end
	  
		it "lists records" do
			Account.current_id = current_account.id
			@company_class.events.each do |event|
				should have_selector 'td', text: event.start_at.strftime('%B %-d, %Y')
				should have_selector 'td', text: event.start_at.strftime('%A')
				should have_selector 'td', text: event.time_range
				should have_selector 'td', text: event.duration
				should have_selector 'td', text: event.location.name
				
				should have_link event.start_at.strftime('%B %-d, %Y'), href: edit_schedule_event_path(event)
				should have_link 'Delete', href: schedule_event_path(event)
	    end
		end
	end
end
