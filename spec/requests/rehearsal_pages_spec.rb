require 'spec_helper'

describe "Rehearsal Pages:" do
	subject { page }
  
  context "#new" do
  	it "has correct title" do
			log_in
	  	click_link 'Daily Schedule'
	  	click_link 'New Rehearsal'
	  	
	  	should have_selector('title', text: 'New Rehearsal')
		  should have_selector('h1', text: 'New Rehearsal')
		end
		
		it "has only active Locations in dropdown" do
			log_in
			FactoryGirl.create(:location, account: current_account, name: 'Location A')
			FactoryGirl.create(:location_inactive, account: current_account, name: 'Location B')
			visit new_rehearsal_path
  		
			should have_selector('option', text: 'Location A')
			should_not have_selector('option', text: 'Location B')
		end
		
		it "has only active Pieces in dropdown" do
			log_in
			FactoryGirl.create(:piece, account: current_account, name: 'Piece A')
			FactoryGirl.create(:piece_inactive, account: current_account, name: 'Piece B')
			visit new_rehearsal_path
  		
			should have_selector('option', text: 'Piece A')
			should_not have_selector('option', text: 'Piece B')
		end
		
		it "has only active Employees in dropdown" do
			log_in
			FactoryGirl.create(:employee, account: current_account, last_name: 'Parker', first_name: 'Peter')
			FactoryGirl.create(:employee_inactive, account: current_account, last_name: 'Kent', first_name: 'Clark')
			visit new_rehearsal_path
  		
			should have_selector('option', text: 'Peter Parker')
			should_not have_selector('option', text: 'Clark Kent')
		end
		
		it "defaults Start Date when date is sent in URL" do
			log_in
			visit new_rehearsal_path(date: Time.zone.today.to_s)
			
			find_field('rehearsal_start_date').value.should == Time.zone.today.strftime("%m/%d/%Y")
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				visit new_rehearsal_path
		  	click_button 'Create'
		
				should have_selector('div.alert-error')
			end
			
			it "doesn't create Rehearsal" do
				log_in
				visit events_path
	  		click_link 'New Rehearsal'
		
				expect { click_button 'Create' }.not_to change(Rehearsal, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Rehearsal without Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				visit new_rehearsal_path
	  		
		  	fill_in "Title", with: "Test Rehearsal"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2012"
		  	fill_in 'From', with: "9AM"
		  	fill_in 'To', with: "11:30AM"
		  	select piece.name, from: "Piece"
				click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Daily Schedule')
				
				should have_selector('div.rehearsal')
				should have_content("Test Rehearsal")
				should have_content(location.name)
				should have_content("9:00 AM")
				should have_content("11:30 AM")
				should have_content(piece.name)
				should have_content("0 invitees")
			end
			
			it "creates new Rehearsal with Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account)
				visit new_rehearsal_path
	  		
		  	fill_in "Title", with: "Test Rehearsal"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2012"
		  	fill_in 'From', with: "9AM"
		  	fill_in 'To', with: "11:30AM"
		  	select piece.name, from: "Piece"
		  	select e1.full_name, from: "Invitees"
				click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Daily Schedule')
				
				should have_selector('div.rehearsal')
				should have_content("Test Rehearsal")
				should have_content(location.name)
				should have_content("9:00 AM")
				should have_content("11:30 AM")
				should have_content(piece.name)
				should have_content("1 invitee")
			end
		end
			
		context "shows warning" do			
			it "when employee is double booked" do
				log_in
				loc1 = FactoryGirl.create(:location, account: current_account)
				loc2 = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account)
				e2 = FactoryGirl.create(:employee, account: current_account)
				e3 = FactoryGirl.create(:employee, account: current_account)
				
				r1 = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc1,
								piece: piece,
								start_date: Time.zone.today,
								start_time: "11 AM",
								end_time: "12 PM")
				FactoryGirl.create(:invitation, event: r1, employee: e1)
				FactoryGirl.create(:invitation, event: r1, employee: e2)
				FactoryGirl.create(:invitation, event: r1, employee: e3)
				
				r2 = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc1,
								piece: piece,
								start_date: Time.zone.today,
								start_time: "12 PM",
								end_time: "1 PM")
				FactoryGirl.create(:invitation, event: r2, employee: e1)
				
				visit new_rehearsal_path
				fill_in "Title", with: "Test Rehearsal"
		  	select loc2.name, from: "Location"
		  	fill_in 'Date', with: Time.zone.today
		  	fill_in 'From', with: "11AM"
		  	fill_in 'To', with: "1PM"
		  	select piece.name, from: "Piece"
		  	select e1.full_name, from: "Invitees"
				click_button 'Create'
		
				should have_selector('div.alert-warning')
				should have_content("people are double booked")
				should have_content(e1.full_name)
				should_not have_content(e2.full_name)
				should_not have_content(e3.full_name)
			end
			
			it "when AGMA Dancer has exceeded their max rehearsal hours per day" do
				log_in
				loc = FactoryGirl.create(:location, account: current_account)
				loc2 = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account, role: 'AGMA Dancer')
				
				r_5hr = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc,
								piece: piece,
								start_date: Time.zone.today,
								start_time: "9 AM",
								end_time: "2 PM")
				FactoryGirl.create(:invitation, event: r_5hr, employee: e1)
				
				visit new_rehearsal_path
				fill_in "Title", with: "Test Rehearsal"
		  	select loc2.name, from: "Location"
		  	fill_in 'Date', with: Time.zone.today
		  	fill_in 'From', with: "2 PM"
		  	fill_in 'To', with: "3:30 PM"
		  	select piece.name, from: "Piece"
		  	select e1.full_name, from: "Invitees"
				click_button 'Create'
		
				should have_selector('div.alert-warning')
				should have_content("over their rehearsal limit")
				should have_content("hrs/day")
				should have_content(e1.full_name)
			end
		end
	end
	
	context "#show" do
		it "has correct title" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			rehearsal = FactoryGirl.create(:rehearsal,
					account: current_account,
					location: location,
					piece: piece,
					start_date: Time.zone.today)
			click_link 'Daily Schedule'
	  	click_link 'View'
	  	
	  	should have_selector('title', text: 'Rehearsal')
		  should have_selector('h1', text: rehearsal.title)
		end
		
		it "has rehearsal info shown" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			rehearsal = FactoryGirl.create(:rehearsal,
					account: current_account,
					location: location,
					piece: piece,
					start_date: Time.zone.today,
					start_time: "11am",
					end_time: "12pm")
			visit rehearsal_path(rehearsal)
	  	
			should have_content(rehearsal.location.name)
		  should have_content(rehearsal.start_date.strftime('%D'))
		  should have_content("11:00 AM to 12:00 PM")
		  should have_content(rehearsal.piece.name)
		end
		
		it "has invitees shown" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			rehearsal = FactoryGirl.create(:rehearsal,
					account: current_account,
					location: location,
					piece: piece,
					start_date: Time.zone.today)
			employee1 = FactoryGirl.create(:employee, account: current_account)
			employee2 = FactoryGirl.create(:employee, account: current_account)
			FactoryGirl.create(:invitation, event: rehearsal, employee: employee1)
			FactoryGirl.create(:invitation, event: rehearsal, employee: employee2)
			
			visit rehearsal_path(rehearsal)
	  	
			should have_content(employee1.full_name)
			should have_content(employee2.full_name)
		end
	end
	
	context "#edit" do
		it "has correct title" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			rehearsal = FactoryGirl.create(:rehearsal,
					account: current_account,
					location: location,
					piece: piece,
					start_date: Time.zone.today)
	  	click_link 'Daily Schedule'
	  	click_link 'Edit'
	  	
	  	should have_selector('title', text: 'Edit Rehearsal')
			should have_selector('h1', text: 'Edit Rehearsal')
		end
		
	  it "record with error" do
	  	log_in
			location = FactoryGirl.create(:location, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			rehearsal = FactoryGirl.create(:rehearsal,
					account: current_account,
					location: location,
					piece: piece,
					start_date: Time.zone.today)
	  	visit edit_rehearsal_path(rehearsal)
	  	
	  	fill_in "Title", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-error')
		end
	
		it "with bad record in URL shows 'Record Not Found' error" do
			pending
			log_in
			edit_rehearsal_path(0)
	
			should have_content('Record Not Found')
		end
		
		it "record with wrong account shows 'Record Not Found' error" do
			pending
			log_in
			rehearsal_wrong_account = FactoryGirl.create(:rehearsal)
			visit edit_rehearsal_path(rehearsal_wrong_account)
	
			should have_content('Record Not Found')
		end
	 
		it "record with valid info saves rehearsal" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			rehearsal = FactoryGirl.create(:rehearsal,
					account: current_account,
					location: location,
					piece: piece,
					start_date: Time.zone.today)
			visit edit_rehearsal_path(rehearsal)
	  	
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
				piece = FactoryGirl.create(:piece, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account)
				e2 = FactoryGirl.create(:employee, account: current_account)
				e3 = FactoryGirl.create(:employee, account: current_account)
				
				r1 = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc1,
								piece: piece,
								start_date: Time.zone.today,
								start_time: "11 AM",
								end_time: "12 PM")
				FactoryGirl.create(:invitation, event: r1, employee: e1)
				FactoryGirl.create(:invitation, event: r1, employee: e2)
				FactoryGirl.create(:invitation, event: r1, employee: e3)
				
				r2 = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc1,
								piece: piece,
								start_date: Time.zone.today,
								start_time: "12 PM",
								end_time: "1 PM")
				FactoryGirl.create(:invitation, event: r2, employee: e1)
				
				r3 = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc2,
								piece: piece,
								start_date: Time.zone.today,
								start_time: "11 AM",
								end_time: "1 PM")
				
				visit edit_rehearsal_path(r3)
		  	select e1.full_name, from: "Invitees"
				click_button 'Update'
		
				should have_selector('div.alert-warning')
				should have_content("people are double booked")
				should have_content(e1.full_name)
				should_not have_content(e2.full_name)
				should_not have_content(e3.full_name)
			end
			
			it "when AGMA Dancer has exceeded their max rehearsal hours per day" do
				log_in
				loc = FactoryGirl.create(:location, account: current_account)
				loc2 = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account, role: 'AGMA Dancer')
				
				r_5hr = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc,
								piece: piece,
								start_date: Time.zone.today,
								start_time: "9 AM",
								end_time: "2 PM")
				FactoryGirl.create(:invitation, event: r_5hr, employee: e1)
				
				r = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc2,
								piece: piece,
								start_date: Time.zone.today,
								start_time: "2 PM",
								end_time: "3:30 PM")
				
				visit edit_rehearsal_path(r)
		  	select e1.full_name, from: "Invitees"
				click_button 'Update'
		
				should have_selector('div.alert-warning')
				should have_content("over their rehearsal limit")
				should have_content("hrs/day")
				should have_content(e1.full_name)
			end
		end
	end
end
