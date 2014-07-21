require 'spec_helper'

describe "CostumeFitting Pages:" do
	subject { page }
  
  context "#new" do
		before do
			log_in
			click_link 'Calendar'
			click_link 'Add Costume Fitting'
		end
		
		it "has correct title" do
			should have_title 'Add Costume Fitting'
		  should have_selector 'h1', text: 'Costume Fittings'
			should have_selector 'h1 small', text: 'Add'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Costume Fittings'
		end
		
		context "with error" do
			it "shows error message" do
				click_button 'Create'
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Costume Fitting" do
				expect { click_button 'Create' }.not_to change(CostumeFitting, :count)
			end
		end
		
		context "shows warning" do
			it "when location is double booked" do
				location = FactoryGirl.create(:location, account: current_account)
				event = FactoryGirl.create(:costume_fitting, account: current_account,
								location: location,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				
				visit new_costume_fitting_path
				fill_in "Title", with: "Test Fitting"
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
				
				f1 = FactoryGirl.create(:costume_fitting, account: current_account,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				FactoryGirl.create(:invitation, event: f1, person: p1)
				FactoryGirl.create(:invitation, event: f1, person: p2)
				FactoryGirl.create(:invitation, event: f1, person: p3)
				
				f2 = FactoryGirl.create(:costume_fitting, account: current_account,
								location: f1.location,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 30)
				FactoryGirl.create(:invitation, event: f2, person: p1)
				
				visit new_costume_fitting_path
				fill_in "Title", with: "Costume Fitting"
				select loc.name, from: "Location"
				fill_in 'Date', with: Time.zone.today
				fill_in 'Start Time', with: "11:30 AM"
				fill_in 'Duration', with: 60
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
			@location = FactoryGirl.create(:location, account: current_account)
			@p1 = FactoryGirl.create(:person, account: current_account)
			click_link 'Calendar'
			open_modal(".fc-slot61 td")	#3:15
			choose 'Costume Fitting'
			click_button 'Next'
		end
		
		context "defaults correct date & time" do
			it "from Daily Calendar" do
				visit events_path+"/2014/1/1"
				open_modal(".fc-slot61 td")	#3:15
			
				choose 'Costume Fitting'
				click_button 'Next'
				
				should have_title 'Add Costume Fitting'
				should have_field 'Date', with: '01/01/2014'
				should have_field 'Time', with: '3:15 PM'
			end
			
			it "from Weekly Calendar" do
				visit events_path+"/2014/1/1"
				find('.fc-button-agendaWeek').click	# Week button
				open_modal(".fc-slot61 td")	#3:15
			
				choose 'Costume Fitting'
				click_button 'Next'
				
				should have_title 'Add Costume Fitting'
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
			should_not have_content 'Piece'	#Using Chosen
			should have_content 'Invitees'	#Using Chosen
		end
	
		context "with valid info" do
			it "creates new Costume Fitting without Invitees" do
				fill_in "Title", with: "Test Fitting"
				select @location.name, from: "Location"
				fill_in 'Date', with: "01/31/2013"
				fill_in 'Start Time', with: "10:15AM"
				fill_in 'Duration', with: 60
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Calendar'
				
				should have_content "Test Fitting"
				should have_content @location.name
				should have_content "10:15 AM - 11:15 AM"
			end
			
			it "creates new Costume Fitting with Invitees" do
				fill_in "Title", with: "Test Fitting"
				select @location.name, from: "Location"
				fill_in 'Date', with: "01/31/2013"
				fill_in 'Start Time', with: "9:15AM"
				fill_in 'Duration', with: 60
				select_from_chosen @p1.full_name, from: 'Invitees'
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Calendar'
				
				should have_content "Test Fitting"
				should have_content "9:15 AM - 10:15 AM"
				
				open_modal(".mash-event")
				click_link "Edit"
				
				should have_content @p1.full_name
			end
		end
	end
	
	context "#edit" do
		before do
			log_in
			@fitting = FactoryGirl.create(:costume_fitting,
					account: current_account,
					start_date: Time.zone.today)
			click_link 'Calendar'
			visit edit_costume_fitting_path(@fitting)
		end
		
		it "has correct title", js: true do
			should have_title 'Edit Costume Fitting'
			should have_selector 'h1', text: 'Costume Fittings'
			should have_selector 'h1 small', text: 'Edit'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Costume Fittings'
		end
		
	  it "record with error" do
			fill_in "Date", with: ""
			click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
		
		context "with warning" do			
			it "shows warning when employee is double booked" do
				p1 = FactoryGirl.create(:person, account: current_account)
				p2 = FactoryGirl.create(:person, account: current_account)
				p3 = FactoryGirl.create(:person, account: current_account)
				
				f1 = FactoryGirl.create(:costume_fitting, account: current_account,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				FactoryGirl.create(:invitation, event: f1, person: p1)
				FactoryGirl.create(:invitation, event: f1, person: p2)
				FactoryGirl.create(:invitation, event: f1, person: p3)
				
				f2 = FactoryGirl.create(:costume_fitting, account: current_account,
								location: f1.location,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 60)
				FactoryGirl.create(:invitation, event: f2, person: p1)
				
				f3 = FactoryGirl.create(:costume_fitting, account: current_account,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 120)
				
				visit edit_costume_fitting_path(f3)
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
	
	context "#edit", js: true do
		before do
			log_in
			@fitting = FactoryGirl.create(:costume_fitting,
					account: current_account,
					start_date: Time.zone.today)
			click_link 'Calendar'
			should have_content @fitting.title
			open_modal(".mash-event")
			click_link "Edit"
		end
		
		it "only shows applicable fields in Overview tab" do
			should have_field 'Title'
			should have_select 'Location'
			should have_field 'Date'
			should have_field 'Start Time'
			should have_field 'Duration'
			should_not have_content 'Piece'	#Using Chosen
			should have_content 'Invitees'	#Using Chosen
		end
	 
		it "record with valid info saves costume fitting" do
			new_title = Faker::Lorem.word
			fill_in "Title", with: new_title
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Calendar'
			should have_content new_title
		end
	end
end
