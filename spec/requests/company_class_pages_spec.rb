require 'spec_helper'

describe "CompanyClass Pages:" do
	subject { page }
	
  context "#new" do
		before do
			log_in
			click_link 'Calendar'
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
		
		context "with error" do
			it "shows error message" do
				click_button 'Create'
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Company Class" do
				expect { click_button 'Create' }.not_to change(CompanyClass, :count)
			end
		end
		
		context "shows warning" do
			it "when location is double booked" do
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
		
				should have_selector 'div.alert-warning', text: "is double booked during this time"
				should have_selector 'div.alert-warning', text: location.name
			end
					
			it "when employee is double booked" do
				loc = FactoryGirl.create(:location, account: current_account)
				p1 = FactoryGirl.create(:person, account: current_account)
				p2 = FactoryGirl.create(:person, account: current_account)
				p3 = FactoryGirl.create(:person, account: current_account)
				
				cc1 = FactoryGirl.create(:company_class, account: current_account,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				FactoryGirl.create(:invitation, event: cc1, person: p1)
				FactoryGirl.create(:invitation, event: cc1, person: p2)
				FactoryGirl.create(:invitation, event: cc1, person: p3)
				
				cc2 = FactoryGirl.create(:company_class, account: current_account,
								location: cc1.location,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 60)
				FactoryGirl.create(:invitation, event: cc2, person: p1)
				
				visit new_company_class_path
				fill_in "Title", with: "Test Class"
				select loc.name, from: "Location"
				fill_in 'Date', with: Time.zone.today
				fill_in 'Start Time', with: "11AM"
				fill_in 'Duration', with: 120
				select p1.full_name, from: "Invitees"
				click_button 'Create'
		
				should have_selector 'div.alert-warning', text: "people are double booked"
				should have_selector 'div.alert-warning', text: p1.full_name
				should_not have_selector 'div.alert-warning', text: p2.full_name
				should_not have_selector 'div.alert-warning', text: p3.full_name
			end
		end
		
		it "has links for Super Admin" do
			should have_link 'Add Company Class'
			should have_link 'Add Rehearsal'
			should have_link 'Add Costume Fitting'
			should have_link 'Add Event'
		end
	end
	
	context "#new", js: true do
		before do
			log_in
			click_link 'Calendar'
			open_modal(".fc-slot61 td")	#3:15
			choose 'Company Class'
			click_button 'Next'
		end

		context "defaults correct date & time" do
			it "from Daily Calendar" do
				visit events_path+"/2014/1/1"
				open_modal(".fc-slot61 td")	#3:15
			
				choose 'Company Class'
				click_button 'Next'
			 	
				should have_title 'Add Company Class'
				should have_field 'Date', with: '01/01/2014'
				should have_field 'Time', with: '3:15 PM'
			end
			
			it "from Weekly Calendar" do
				visit events_path+"/2014/1/1"
				find('.fc-button-agendaWeek').click	# Week button
				open_modal(".fc-slot61 td")	#3:15
			
				choose 'Company Class'
				click_button 'Next'
			 	
				should have_title 'Add Company Class'
				should have_field 'Date', with: '01/01/2014'
				should have_field 'Time', with: '3:15 PM'
			end
		end
		
		it "only shows applicable fields in Overview tab" do
			should have_field 'Title'
			should have_select 'Location'
			should have_field 'Date'
			should have_field 'Start Time'
			should have_field 'Duration'
			should_not have_content 'Piece' 	#Using Chosen
			should have_content 'Invitees'	#Using Chosen
		end
	
		context "with valid info" do
			it "creates new Company Class without Invitees" do
				location = FactoryGirl.create(:location, account: current_account)
				visit new_company_class_path
				
				fill_in "Title", with: "Test Company Class"
				select location.name, from: "Location"
				fill_in 'Date', with: "01/31/2013"
				fill_in 'Start Time', with: "10:15AM"
				fill_in 'Duration', with: 60
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Calendar'
				
				should have_content "Test Company Class"
				should have_content location.name
				should have_content "10:15 AM - 11:15 AM"
			end
			
			it "creates new Company Class with Invitees" do
				location = FactoryGirl.create(:location, account: current_account)
				p1 = FactoryGirl.create(:person, account: current_account)
				visit new_company_class_path
	  		
				fill_in "Title", with: "Test Company Class"
				select location.name, from: "Location"
				fill_in 'Date', with: "01/31/2013"
				fill_in 'Start Time', with: "9:15AM"
				fill_in 'Duration', with: 60
				select_from_chosen p1.full_name, from: 'Invitees'
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Calendar'
				
				should have_content "Test Company Class"
				should have_content location.name
				should have_content "9:15 AM - 10:15 AM"
				
				open_modal(".mash-event")
				click_link "Edit"
				
				should have_content p1.full_name
			end
		end
	end
	
	context "#edit" do
		before do
			log_in
			@cclass = FactoryGirl.create(:company_class,
					account: current_account,
					start_date: Time.zone.today)
			click_link 'Calendar'
		end
		
		it "has correct title", js: true do
			should have_content @cclass.title
			open_modal(".mash-event")
			click_link "Edit"
	  	
			should have_title 'Edit Company Class'
			should have_selector 'h1', text: 'Company Classes'
			should have_selector 'h1 small', text: 'Edit'
		end
		
		it "has correct Navigation" do
			visit edit_company_class_path(@cclass)
	
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Company Classes'
		end
		
		it "only shows applicable fields in Overview tab", js: true do
			visit edit_company_class_path(@cclass)
	
			should have_field 'Title'
			should have_select 'Location'
			should have_field 'Date'
			should have_field 'Start Time'
			should have_field 'Duration'
			should_not have_content 'Piece'	#Using Chosen
			should have_content 'Invitees'	#Using Chosen
		end
		
	  it "record with error" do
			visit edit_company_class_path(@cclass)
	  	
			fill_in "Date", with: ""
			click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "record with valid info saves company class", js: true do
			visit edit_company_class_path(@cclass)
	  	
			new_title = Faker::Lorem.word
			fill_in "Title", with: new_title
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Calendar'
			should have_content new_title
		end
		
		context "with warning" do			
			it "shows warning when employee is double booked" do
				p1 = FactoryGirl.create(:person, account: current_account)
				p2 = FactoryGirl.create(:person, account: current_account)
				p3 = FactoryGirl.create(:person, account: current_account)
				
				cc1 = FactoryGirl.create(:company_class, account: current_account,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				FactoryGirl.create(:invitation, event: cc1, person: p1)
				FactoryGirl.create(:invitation, event: cc1, person: p2)
				FactoryGirl.create(:invitation, event: cc1, person: p3)
				
				cc2 = FactoryGirl.create(:company_class, account: current_account,
								location: cc1.location,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 60)
				FactoryGirl.create(:invitation, event: cc2, person: p1)
				
				cc3 = FactoryGirl.create(:company_class, account: current_account,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 120)
				
				visit edit_company_class_path(cc3)
				select p1.full_name, from: "Invitees"
				click_button 'Update'
		
				should have_selector 'div.alert-warning', text: "people are double booked"
				should have_selector 'div.alert-warning', text: p1.full_name
				should_not have_selector 'div.alert-warning', text: p2.full_name
				should_not have_selector 'div.alert-warning', text: p3.full_name
			end
		end
		
		it "has links for Super Admin" do
			should have_link 'Add Company Class'
			should have_link 'Add Rehearsal'
			should have_link 'Add Costume Fitting'
			should have_link 'Add Event'
		end
	end
end
