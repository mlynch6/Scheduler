require 'spec_helper'

describe "CompanyClass Pages:" do
	subject { page }
  
  context "#new" do
  	it "has correct title" do
			log_in
	  	click_link 'Calendar'
	  	click_link 'New Company Class'
	  	
	  	should have_selector('title', text: 'New Company Class')
		  should have_selector('h1', text: 'New Company Class')
		end
		
		it "has correct Navigation" do
			log_in
			visit new_company_class_path
	
			should have_selector('li.active', text: 'Calendar')
			should have_selector('li.active', text: 'New Company Class')
		end
		
		it "has only active Locations in dropdown" do
			log_in
			FactoryGirl.create(:location, account: current_account, name: 'Location A')
			FactoryGirl.create(:location_inactive, account: current_account, name: 'Location B')
			visit new_company_class_path
  		
			should have_selector('option', text: 'Location A')
			should_not have_selector('option', text: 'Location B')
		end
		
		it "has only active Employees in dropdown" do
			log_in
			FactoryGirl.create(:employee, account: current_account, last_name: 'Parker', first_name: 'Peter')
			FactoryGirl.create(:employee_inactive, account: current_account, last_name: 'Kent', first_name: 'Clark')
			visit new_company_class_path
  		
			should have_selector('option', text: 'Peter Parker')
			should_not have_selector('option', text: 'Clark Kent')
		end
		
		it "defaults Start Date when date is sent in URL" do
			log_in
			visit new_company_class_path(date: Time.zone.today.to_s)
			
			find_field('company_class_start_date').value.should == Time.zone.today.strftime("%m/%d/%Y")
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				visit new_company_class_path
		  	click_button 'Create'
		
				should have_selector('div.alert-danger')
			end
			
			it "doesn't create Company Class" do
				log_in
				visit new_company_class_path
		
				expect { click_button 'Create' }.not_to change(CompanyClass, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Company Class without Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				visit new_company_class_path
	  		
		  	fill_in "Title", with: "Test Company Class"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2013"
		  	fill_in 'From', with: "10AM"
		  	fill_in 'To', with: "11AM"
		  	click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Daily Schedule')
				
				should have_content("Test Company Class")
				should have_content(location.name)
				should have_content("10:00 AM")
				should have_content("11:00 AM")
			end
			
			it "creates new Company Class with Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account)
				visit new_company_class_path
	  		
		  	fill_in "Title", with: "Test Company Class"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2013"
		  	fill_in 'From', with: "9AM"
		  	fill_in 'To', with: "10:30AM"
		  	select e1.full_name, from: "Invitees"
				click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Daily Schedule')
				
				should have_content("Test Company Class")
				should have_content(location.name)
				should have_content("9:00 AM")
				should have_content("10:30 AM")
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
				
				cc1 = FactoryGirl.create(:company_class, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "11 AM",
								end_time: "12 PM")
				FactoryGirl.create(:invitation, event: cc1, employee: e1)
				FactoryGirl.create(:invitation, event: cc1, employee: e2)
				FactoryGirl.create(:invitation, event: cc1, employee: e3)
				
				cc2 = FactoryGirl.create(:company_class, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "12 PM",
								end_time: "1 PM")
				FactoryGirl.create(:invitation, event: cc2, employee: e1)
				
				visit new_company_class_path
				fill_in "Title", with: "Test Rehearsal"
		  	select loc2.name, from: "Location"
		  	fill_in 'Date', with: Time.zone.today
		  	fill_in 'From', with: "11AM"
		  	fill_in 'To', with: "1PM"
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
			cclass = FactoryGirl.create(:company_class,
					account: current_account,
					location: location,
					start_date: Time.zone.today)
			click_link 'Calendar'
	  	click_link 'Daily Schedule'
	  	click_link 'Edit'
	  	
	  	should have_selector('title', text: 'Edit Company Class')
			should have_selector('h1', text: 'Edit Company Class')
		end
		
		it "has correct Navigation" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			cclass = FactoryGirl.create(:company_class,
					account: current_account,
					location: location,
					start_date: Time.zone.today)
			visit edit_company_class_path(cclass)
	
			should have_selector('li.active', text: 'Calendar')
			should have_selector('li.active', text: 'Daily Schedule')
		end
		
	  it "record with error" do
	  	log_in
			location = FactoryGirl.create(:location, account: current_account)
			cclass = FactoryGirl.create(:company_class,
					account: current_account,
					location: location,
					start_date: Time.zone.today)
	  	visit edit_company_class_path(cclass)
	  	
	  	fill_in "Date", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-danger')
		end
	 
		it "record with valid info saves company class" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			cclass = FactoryGirl.create(:company_class,
					account: current_account,
					location: location,
					start_date: Time.zone.today)
			visit edit_company_class_path(cclass)
	  	
	  	new_title = Faker::Lorem.word
			fill_in "Title", with: new_title
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Daily Schedule')
			should have_content(new_title)
		end
		
		context "with warning" do			
			it "shows warning when employee is double booked" do
				log_in
				loc1 = FactoryGirl.create(:location, account: current_account)
				loc2 = FactoryGirl.create(:location, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account)
				e2 = FactoryGirl.create(:employee, account: current_account)
				e3 = FactoryGirl.create(:employee, account: current_account)
				
				cc1 = FactoryGirl.create(:company_class, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "11 AM",
								end_time: "12 PM")
				FactoryGirl.create(:invitation, event: cc1, employee: e1)
				FactoryGirl.create(:invitation, event: cc1, employee: e2)
				FactoryGirl.create(:invitation, event: cc1, employee: e3)
				
				cc2 = FactoryGirl.create(:company_class, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "12 PM",
								end_time: "1 PM")
				FactoryGirl.create(:invitation, event: cc2, employee: e1)
				
				cc3 = FactoryGirl.create(:company_class, account: current_account,
								location: loc2,
								start_date: Time.zone.today,
								start_time: "11 AM",
								end_time: "1 PM")
				
				visit edit_company_class_path(cc3)
		  	select e1.full_name, from: "Invitees"
				click_button 'Update'
		
				should have_selector('div.alert-warning', text: "people are double booked")
				should have_selector('div.alert-warning', text: e1.full_name)
				should_not have_selector('div.alert-warning', text: e2.full_name)
				should_not have_selector('div.alert-warning', text: e3.full_name)
			end
		end
	end
end
