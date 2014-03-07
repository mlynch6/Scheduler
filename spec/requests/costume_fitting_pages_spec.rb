require 'spec_helper'

describe "CostumeFitting Pages:" do
	subject { page }
  
  context "#new" do
  	it "has correct title" do
			log_in
	  	click_link 'Calendar'
	  	click_link 'New Costume Fitting'
	  	
	  	has_title?('New Costume Fitting').should be_true
		  should have_selector('h1', text: 'New Costume Fitting')
		end
		
		it "has correct Navigation" do
			log_in
			visit new_costume_fitting_path
	
			should have_selector('li.active', text: 'Calendar')
			should have_selector('li.active', text: 'New Costume Fitting')
		end
		
		it "only shows applicable fields in Overview tab", js: true do
			log_in
			visit new_costume_fitting_path
	
			has_field?('Title').should be_true
			has_select?('Location').should be_true
			has_field?('Date').should be_true
			has_field?('Start Time').should be_true
			has_field?('Duration').should be_true
			should_not have_content('Piece')	#Using Chosen
			should have_content('Invitees')	#Using Chosen
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				visit new_costume_fitting_path
		  	click_button 'Create'
		
				should have_selector('div.alert-danger')
			end
			
			it "doesn't create Costume Fitting" do
				log_in
				visit new_costume_fitting_path
		
				expect { click_button 'Create' }.not_to change(CostumeFitting, :count)
			end
		end
	
		context "with valid info", js: true do
			it "creates new Costume Fitting without Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				visit new_costume_fitting_path
	  		
		  	fill_in "Title", with: "Test Fitting"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2013"
		  	fill_in 'Start Time', with: "10AM"
		  	fill_in 'Duration', with: 60
		  	click_button 'Create'
		
				should have_selector('div.alert-success')
				has_title?('Calendar').should be_true
				
				should have_content("Test Fitting")
				should have_content(location.name)
				should have_content("10:00 AM - 11:00 AM")
			end
			
			it "creates new Costume Fitting with Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account)
				visit new_costume_fitting_path
	  		
		  	fill_in "Title", with: "Test Fitting"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2013"
		  	fill_in 'Start Time', with: "9AM"
		  	fill_in 'Duration', with: 30
		  	select_from_chosen e1.full_name, from: 'Invitees'
				click_button 'Create'
		
				should have_selector('div.alert-success')
				has_title?('Calendar').should be_true
				
				should have_content("Test Fitting")
				should have_content("9:00 AM - 9:30 AM")
				
				open_modal(".mash-event")
				click_link "Edit"
				
				should have_content(e1.full_name)
			end
		end
		
		context "shows warning" do
			it "when location is double booked" do
				log_in
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
				
				f1 = FactoryGirl.create(:costume_fitting, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				FactoryGirl.create(:invitation, event: f1, employee: e1)
				FactoryGirl.create(:invitation, event: f1, employee: e2)
				FactoryGirl.create(:invitation, event: f1, employee: e3)
				
				f2 = FactoryGirl.create(:costume_fitting, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 30)
				FactoryGirl.create(:invitation, event: f2, employee: e1)
				
				visit new_costume_fitting_path
				fill_in "Title", with: "Costume Fitting"
		  	select loc2.name, from: "Location"
		  	fill_in 'Date', with: Time.zone.today
		  	fill_in 'Start Time', with: "11:30 AM"
		  	fill_in 'Duration', with: 60
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
			fitting = FactoryGirl.create(:costume_fitting,
					account: current_account,
					location: location,
					start_date: Time.zone.today)
	  	click_link 'Calendar'
	  	
	  	should have_content(fitting.title)
			open_modal(".mash-event")
			click_link "Edit"
	  	
	  	has_title?('Edit Costume Fitting').should be_true
	  	should have_selector('h1', text: 'Edit Costume Fitting')
		end
		
		it "has correct Navigation" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			fitting = FactoryGirl.create(:costume_fitting,
					account: current_account,
					location: location,
					start_date: Time.zone.today)
	  	visit edit_costume_fitting_path(fitting)
	
			should have_selector('li.active', text: 'Calendar')
		end
		
		it "only shows applicable fields in Overview tab", js: true do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			fitting = FactoryGirl.create(:costume_fitting,
					account: current_account,
					location: location,
					start_date: Time.zone.today)
	  	visit edit_costume_fitting_path(fitting)
	
			has_field?('Title').should be_true
			has_select?('Location').should be_true
			has_field?('Date').should be_true
			has_field?('Start Time').should be_true
			has_field?('Duration').should be_true
			should_not have_content('Piece')	#Using Chosen
			should have_content('Invitees')	#Using Chosen
		end
		
	  it "record with error" do
	  	log_in
			location = FactoryGirl.create(:location, account: current_account)
			fitting = FactoryGirl.create(:costume_fitting,
					account: current_account,
					location: location,
					start_date: Time.zone.today)
	  	visit edit_costume_fitting_path(fitting)
	  	
	  	fill_in "Date", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-danger')
		end
	 
		it "record with valid info saves costume fitting", js: true do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			fitting = FactoryGirl.create(:costume_fitting,
					account: current_account,
					location: location,
					start_date: Time.zone.today)
			visit edit_costume_fitting_path(fitting)
	  	
	  	new_title = Faker::Lorem.word
			fill_in "Title", with: new_title
			click_button 'Update'
	
			should have_selector('div.alert-success')
			has_title?('Calendar').should be_true
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
				
				f1 = FactoryGirl.create(:costume_fitting, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				FactoryGirl.create(:invitation, event: f1, employee: e1)
				FactoryGirl.create(:invitation, event: f1, employee: e2)
				FactoryGirl.create(:invitation, event: f1, employee: e3)
				
				f2 = FactoryGirl.create(:costume_fitting, account: current_account,
								location: loc1,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 60)
				FactoryGirl.create(:invitation, event: f2, employee: e1)
				
				f3 = FactoryGirl.create(:costume_fitting, account: current_account,
								location: loc2,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 120)
				
				visit edit_costume_fitting_path(f3)
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
