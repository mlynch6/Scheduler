require 'spec_helper'

describe "Rehearsal Pages:" do
	subject { page }
  
  context "#new" do
		before do
			log_in
			click_link 'Calendar'
			click_link 'Add Rehearsal'
		end
		
		it "has correct title" do
			should have_title 'Add Rehearsal'
		  should have_selector 'h1', text: 'Rehearsals'
			should have_selector 'h1 small', text: 'Add'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Rehearsals'
		end
		
		context "with error" do
			it "shows error message" do
				click_button 'Create'
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Rehearsal" do
				expect { click_button 'Create' }.not_to change(Rehearsal, :count)
			end
		end
		
		context "shows warning" do
			it "when location is double booked" do
				event = FactoryGirl.create(:rehearsal, account: current_account,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				
				visit new_rehearsal_path
				fill_in "Title", with: "Test Rehearsal"
				select event.location.name, from: "Location"
				fill_in 'Date', with: Time.zone.today
				fill_in 'Start Time', with: "11AM"
				fill_in 'Duration', with: 120
				select event.piece.name, from: "Piece"
				click_button 'Create'
		
				should have_selector 'div.alert-warning', text: "is double booked during this time"
				should have_selector 'div.alert-warning', text: event.location.name
			end
				
			it "when employee is double booked" do
				loc = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				p1 = FactoryGirl.create(:person, account: current_account)
				p2 = FactoryGirl.create(:person, account: current_account)
				p3 = FactoryGirl.create(:person, account: current_account)
				
				r1 = FactoryGirl.create(:rehearsal, account: current_account,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				FactoryGirl.create(:invitation, event: r1, person: p1)
				FactoryGirl.create(:invitation, event: r1, person: p2)
				FactoryGirl.create(:invitation, event: r1, person: p3)
				
				r2 = FactoryGirl.create(:rehearsal, account: current_account,
								location: r1.location,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 60)
				FactoryGirl.create(:invitation, event: r2, person: p1)
				
				visit new_rehearsal_path
				fill_in "Title", with: "Test Rehearsal"
				select loc.name, from: "Location"
				fill_in 'Date', with: Time.zone.today
				fill_in 'Start Time', with: "11AM"
				fill_in 'Duration', with: 120
				select piece.name, from: "Piece"
				select p1.full_name, from: "Invitees"
				click_button 'Create'
		
				should have_selector 'div.alert-warning', text: "people are double booked"
				should have_selector 'div.alert-warning', text: p1.full_name
				should_not have_selector 'div.alert-warning', text: p2.full_name
				should_not have_selector 'div.alert-warning', text: p3.full_name
			end
			
			it "when AGMA Dancer has exceeded their max rehearsal hours per day" do
				loc = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				p1 = FactoryGirl.create(:person, :agma, account: current_account)
				
				r_5hr = FactoryGirl.create(:rehearsal, account: current_account,
								start_date: Time.zone.today,
								start_time: "9 AM",
								duration: 300)
				FactoryGirl.create(:invitation, event: r_5hr, person: p1)
				
				visit new_rehearsal_path
				fill_in "Title", with: "Test Rehearsal"
				select loc.name, from: "Location"
				fill_in 'Date', with: Time.zone.today
				fill_in 'Start Time', with: "2 PM"
				fill_in 'Duration', with: 90
				select piece.name, from: "Piece"
				select p1.full_name, from: "Invitees"
				click_button 'Create'
				
				should have_selector 'div.alert-warning', text: "over their rehearsal limit"
				should have_selector 'div.alert-warning', text: "hrs/day"
				should have_selector 'div.alert-warning', text: p1.full_name
			end
			
			it "when AGMA Dancer has exceeded their max rehearsal hours per week" do
				loc = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				p1 = FactoryGirl.create(:person, :agma, account: current_account)
				date = Date.new(2013,1,7)
				for i in 0..4 do
					r_6hr = FactoryGirl.create(:rehearsal, account: current_account,
									start_date: date + i.days,
									start_time: "9 AM",
									duration: 360)
					FactoryGirl.create(:invitation, event: r_6hr, person: p1)
				end
				
				visit new_rehearsal_path
				fill_in "Title", with: "Test Rehearsal"
				select loc.name, from: "Location"
				fill_in 'Date', with: date + 5.days
				fill_in 'Start Time', with: "3 PM"
				fill_in 'Duration', with: 30
				select piece.name, from: "Piece"
				select p1.full_name, from: "Invitees"
				click_button 'Create'
				
				should have_selector 'div.alert-warning', text: "over their rehearsal limit"
				should have_selector 'div.alert-warning', text: "hrs/week"
				should have_selector 'div.alert-warning', text: p1.full_name
			end
		end
	end
	
  context "#new", js: true do
		before do
			log_in
			click_link 'Calendar'
			open_modal(".fc-slot61 td")	#3:15
			choose 'Rehearsal'
			click_button 'Next'
		end
		
		context "defaults correct date & time" do
			it "from Daily Calendar" do
				visit events_path+"/2014/1/1"
				open_modal(".fc-slot61 td")	#3:15
			
				choose 'Rehearsal'
				click_button 'Next'
			 	
				should have_title 'Add Rehearsal'
				should have_field 'Date', with: '01/01/2014'
				should have_field 'Time', with: '3:15 PM'
			end
			
			it "from Weekly Calendar" do
				visit events_path+"/2014/1/1"
				find('.fc-button-agendaWeek').click	# Week button
				open_modal(".fc-slot61 td")	#3:15
			
				choose 'Rehearsal'
				click_button 'Next'
			 	
				should have_title 'Add Rehearsal'
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
			should have_content 'Piece'	#Using Chosen
			should have_content 'Invitees'	#Using Chosen
		end
	
		context "with valid info" do
			it "creates new Rehearsal without Invitees" do
				location = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				visit new_rehearsal_path
	  		
				fill_in "Title", with: "Test Rehearsal"
				select location.name, from: "Location"
				fill_in 'Date', with: "01/31/2012"
				fill_in 'Start Time', with: "9:15AM"
				fill_in 'Duration', with: 60
				select_from_chosen piece.name, from: 'Piece'
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Calendar'
				
				should have_content "Test Rehearsal"
				should have_content location.name
				should have_content "9:15 AM - 10:15 AM"
			end
			
			it "creates new Rehearsal with Invitees" do
				location = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				p1 = FactoryGirl.create(:person, account: current_account)
				visit new_rehearsal_path
	  		
				fill_in "Title", with: "Test Rehearsal"
				select location.name, from: "Location"
				fill_in 'Date', with: "01/31/2012"
				fill_in 'Start Time', with: "9:15AM"
				fill_in 'Duration', with: 60
				select_from_chosen piece.name, from: 'Piece'
				select_from_chosen p1.full_name, from: 'Invitees'
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Calendar'
				
				should have_content "Test Rehearsal"
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
			@rehearsal = FactoryGirl.create(:rehearsal,
					account: current_account,
					start_date: Time.zone.today)
			
			visit edit_rehearsal_path(@rehearsal)
		end
		
		it "has correct title" do
	  	should have_title 'Edit Rehearsal'
	  	should have_selector 'h1', text: 'Rehearsals'
			should have_selector 'h1 small', text: 'Edit'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Rehearsals'
		end
		
	  it "record with error" do
			fill_in "Title", with: ""
			click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
		
		context "with warning" do			
			it "shows warning when employee is double booked" do
				loc = FactoryGirl.create(:location, account: current_account)
				p1 = FactoryGirl.create(:person, account: current_account)
				p2 = FactoryGirl.create(:person, account: current_account)
				p3 = FactoryGirl.create(:person, account: current_account)
				
				r1 = FactoryGirl.create(:rehearsal, account: current_account,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 60)
				FactoryGirl.create(:invitation, event: r1, person: p1)
				FactoryGirl.create(:invitation, event: r1, person: p2)
				FactoryGirl.create(:invitation, event: r1, person: p3)
				
				r2 = FactoryGirl.create(:rehearsal, account: current_account,
								location: r1.location,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 60)
				FactoryGirl.create(:invitation, event: r2, person: p1)
				
				r3 = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 120)
				
				visit edit_rehearsal_path(r3)
				select p1.full_name, from: "Invitees"
				click_button 'Update'
		
				should have_selector 'div.alert-warning', text: "people are double booked"
				should have_selector 'div.alert-warning', text: p1.full_name
				should_not have_selector 'div.alert-warning', text: p2.full_name
				should_not have_selector 'div.alert-warning', text: p3.full_name
			end
			
			it "when AGMA Dancer has exceeded their max rehearsal hours per day" do
				p1 = FactoryGirl.create(:person, :agma, account: current_account)
				r_5hr = FactoryGirl.create(:rehearsal, account: current_account,
								start_date: Time.zone.today,
								start_time: "9 AM",
								duration: 300)
				FactoryGirl.create(:invitation, event: r_5hr, person: p1)
				
				r = FactoryGirl.create(:rehearsal, account: current_account,
								start_date: Time.zone.today,
								start_time: "2 PM",
								duration: 90)
				
				visit edit_rehearsal_path(r)
				select p1.full_name, from: "Invitees"
				click_button 'Update'
				
				should have_selector 'div.alert-warning', text: "over their rehearsal limit"
				should have_selector 'div.alert-warning', text: "hrs/day"
				should have_selector 'div.alert-warning', text: p1.full_name
			end
			
			it "when AGMA Dancer has exceeded their max rehearsal hours per week" do
				loc = FactoryGirl.create(:location, account: current_account)
				p1 = FactoryGirl.create(:person, :agma, account: current_account)
				
				date = Date.new(2013,1,7)
				for i in 0..4 do
					r_6hr = FactoryGirl.create(:rehearsal, account: current_account,
									start_date: date + i.days,
									start_time: "9 AM",
									duration: 360)
					FactoryGirl.create(:invitation, event: r_6hr, person: p1)
				end
				
				r = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc,
								start_date: date + 5.days,
								start_time: "3 PM",
								duration: 30)
				
				visit edit_rehearsal_path(r)
				select p1.full_name, from: "Invitees"
				click_button 'Update'
				
				should have_selector 'div.alert-warning', text: "over their rehearsal limit"
				should have_selector 'div.alert-warning', text: "hrs/week"
				should have_selector 'div.alert-warning', text: p1.full_name
			end
		end
	end
	
	context "#edit", js: true do
		before do
			log_in
			@rehearsal = FactoryGirl.create(:rehearsal,
					account: current_account,
					start_date: Time.zone.today)
			
			click_link 'Calendar'
			should have_content @rehearsal.title
			open_modal(".mash-event")
			click_link "Edit"
		end
		
		it "only shows applicable fields in Overview tab" do
			should have_field 'Title'
			should have_select 'Location'
			should have_field 'Date'
			should have_field 'Start Time'
			should have_field 'Duration'
			should have_content 'Piece'	#Using Chosen
			should have_content 'Invitees'	#Using Chosen
		end
	 
		it "record with valid info saves rehearsal" do
			new_title = Faker::Lorem.word
			fill_in "Title", with: new_title
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Calendar'
			should have_content new_title
		end
	end
end
