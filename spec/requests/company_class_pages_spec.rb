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
		
		it "only shows applicable fields", js: true do
			log_in
	  	visit new_company_class_path
	
			should_not have_selector('label', text: 'Piece')
		end
		
		it "defaults Start Date when date is sent in URL" do
			log_in
			visit new_company_class_path(date: Time.zone.today.to_s)
			
			find_field('event_start_date').value.should == Time.zone.today.strftime("%m/%d/%Y")
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
	
		context "with valid info", js: true do
			it "creates new Company Class without Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				visit new_company_class_path
	  		
		  	fill_in "Title", with: "Test Company Class"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2013"
		  	fill_in 'Start Time', with: "10AM"
		  	fill_in 'Duration', with: 60
		  	click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('h1', text: 'Calendar')
				
				should have_content("Test Company Class")
				should have_content(location.name)
				should have_content("10:00 AM - 11:00 AM")
			end
			
			it "creates new Company Class with Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account)
				visit new_company_class_path
	  		
		  	fill_in "Title", with: "Test Company Class"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2013"
		  	fill_in 'Start Time', with: "9AM"
		  	fill_in 'Duration', with: 90
		  	select_from_chosen e1.full_name, from: 'Invitees'
				click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('h1', text: 'Calendar')
				
				should have_content("Test Company Class")
				should have_content(location.name)
				should have_content("9:00 AM - 10:30 AM")
				
				open_modal(".mash-event")
				click_link "Edit"
				
				should have_content(e1.full_name)
			end
		end
		
		context "shows warning" do
			it "when location is double booked" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				
				event = FactoryGirl.create(:company_class, account: current_account,
								location: location,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				
				visit new_company_class_path
				fill_in "Title", with: "Test Class"
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
				
				cc1 = FactoryGirl.create(:company_class, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				FactoryGirl.create(:invitation, event: cc1, employee: e1)
				FactoryGirl.create(:invitation, event: cc1, employee: e2)
				FactoryGirl.create(:invitation, event: cc1, employee: e3)
				
				cc2 = FactoryGirl.create(:company_class, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 60)
				FactoryGirl.create(:invitation, event: cc2, employee: e1)
				
				visit new_company_class_path
				fill_in "Title", with: "Test Class"
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
			cclass = FactoryGirl.create(:company_class,
					account: current_account,
					location: location,
					start_date: Time.zone.today)
			click_link 'Calendar'
			
	  	should have_content(cclass.title)
			open_modal(".mash-event")
			click_link "Edit"
	  	
	  	should have_selector('h1', text: 'Edit Company Class')
		end
		
		it "has correct Navigation" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			cclass = FactoryGirl.create(:company_class, account: current_account,
					location: location,
					start_date: Time.zone.today)
			visit edit_company_class_path(cclass)
	
			should have_selector('li.active', text: 'Calendar')
		end
		
		it "only shows applicable fields", js: true do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			cclass = FactoryGirl.create(:company_class, account: current_account,
					location: location,
					start_date: Time.zone.today)
	  	visit edit_company_class_path(cclass)
	
			should_not have_selector('label', text: 'Piece')
		end
		
	  it "record with error" do
	  	log_in
			location = FactoryGirl.create(:location, account: current_account)
			cclass = FactoryGirl.create(:company_class, account: current_account,
					location: location,
					start_date: Time.zone.today)
	  	visit edit_company_class_path(cclass)
	  	
	  	fill_in "Date", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-danger')
		end
	 
		it "record with valid info saves company class", js: true do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			cclass = FactoryGirl.create(:company_class, account: current_account,
					location: location,
					start_date: Time.zone.today)
			visit edit_company_class_path(cclass)
	  	
	  	new_title = Faker::Lorem.word
			fill_in "Title", with: new_title
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('h1', text: 'Calendar')
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
								duration: 60)
				FactoryGirl.create(:invitation, event: cc1, employee: e1)
				FactoryGirl.create(:invitation, event: cc1, employee: e2)
				FactoryGirl.create(:invitation, event: cc1, employee: e3)
				
				cc2 = FactoryGirl.create(:company_class, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 60)
				FactoryGirl.create(:invitation, event: cc2, employee: e1)
				
				cc3 = FactoryGirl.create(:company_class, account: current_account,
								location: loc2,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 120)
				
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
