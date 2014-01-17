require 'spec_helper'

describe "Rehearsal Pages:" do
	subject { page }
  
  context "#new" do
  	it "has correct title" do
			log_in
	  	click_link 'Calendar'
	  	click_link 'New Rehearsal'
	  	
	  	should have_selector('title', text: 'New Rehearsal')
		  should have_selector('h1', text: 'New Rehearsal')
		end
		
		it "has correct Navigation" do
			log_in
			visit new_rehearsal_path
	
			should have_selector('li.active', text: 'Calendar')
			should have_selector('li.active', text: 'New Rehearsal')
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
		
				should have_selector('div.alert-danger')
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
		  	fill_in 'Duration', with: 150
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
		  	fill_in 'Duration', with: 150
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
								duration: 60)
				FactoryGirl.create(:invitation, event: r1, employee: e1)
				FactoryGirl.create(:invitation, event: r1, employee: e2)
				FactoryGirl.create(:invitation, event: r1, employee: e3)
				
				r2 = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc1,
								piece: piece,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 60)
				FactoryGirl.create(:invitation, event: r2, employee: e1)
				
				visit new_rehearsal_path
				fill_in "Title", with: "Test Rehearsal"
		  	select loc2.name, from: "Location"
		  	fill_in 'Date', with: Time.zone.today
		  	fill_in 'From', with: "11AM"
		  	fill_in 'Duration', with: 120
		  	select piece.name, from: "Piece"
		  	select e1.full_name, from: "Invitees"
				click_button 'Create'
		
				should have_selector('div.alert-warning', text: "people are double booked")
				should have_selector('div.alert-warning', text: e1.full_name)
				should_not have_selector('div.alert-warning', text: e2.full_name)
				should_not have_selector('div.alert-warning', text: e3.full_name)
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
								duration: 300)
				FactoryGirl.create(:invitation, event: r_5hr, employee: e1)
				
				visit new_rehearsal_path
				fill_in "Title", with: "Test Rehearsal"
		  	select loc2.name, from: "Location"
		  	fill_in 'Date', with: Time.zone.today
		  	fill_in 'From', with: "2 PM"
		  	fill_in 'Duration', with: 90
		  	select piece.name, from: "Piece"
		  	select e1.full_name, from: "Invitees"
				click_button 'Create'
				
				should have_selector('div.alert-warning', text: "over their rehearsal limit")
				should have_selector('div.alert-warning', text: "hrs/day")
				should have_selector('div.alert-warning', text: e1.full_name)
			end
			
			it "when AGMA Dancer has exceeded their max rehearsal hours per week" do
				log_in
				loc = FactoryGirl.create(:location, account: current_account)
				loc2 = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account, role: 'AGMA Dancer')
				
				date = Date.new(2013,1,7)
				for i in 0..4 do
					r_6hr = FactoryGirl.create(:rehearsal, account: current_account,
									location: loc,
									piece: piece,
									start_date: date + i.days,
									start_time: "9 AM",
									duration: 360)
					FactoryGirl.create(:invitation, event: r_6hr, employee: e1)
				end
				
				visit new_rehearsal_path
				fill_in "Title", with: "Test Rehearsal"
		  	select loc2.name, from: "Location"
		  	fill_in 'Date', with: date + 5.days
		  	fill_in 'From', with: "3 PM"
		  	fill_in 'Duration', with: 30
		  	select piece.name, from: "Piece"
		  	select e1.full_name, from: "Invitees"
				click_button 'Create'
				
				should have_selector('div.alert-warning', text: "over their rehearsal limit")
				should have_selector('div.alert-warning', text: "hrs/week")
				should have_selector('div.alert-warning', text: e1.full_name)
			end
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
	  	click_link 'Calendar'
	  	click_link 'Daily Schedule'
	  	click_link 'Edit'
	  	
	  	should have_selector('title', text: 'Edit Rehearsal')
			should have_selector('h1', text: 'Edit Rehearsal')
		end
		
		it "has correct Navigation" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			rehearsal = FactoryGirl.create(:rehearsal,
					account: current_account,
					location: location,
					piece: piece,
					start_date: Time.zone.today)
	  	visit edit_rehearsal_path(rehearsal)
	
			should have_selector('li.active', text: 'Calendar')
			should have_selector('li.active', text: 'Daily Schedule')
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
	
			should have_selector('div.alert-danger')
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
								duration: 60)
				FactoryGirl.create(:invitation, event: r1, employee: e1)
				FactoryGirl.create(:invitation, event: r1, employee: e2)
				FactoryGirl.create(:invitation, event: r1, employee: e3)
				
				r2 = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc1,
								piece: piece,
								start_date: Time.zone.today,
								start_time: "12 PM",
								duration: 60)
				FactoryGirl.create(:invitation, event: r2, employee: e1)
				
				r3 = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc2,
								piece: piece,
								start_date: Time.zone.today,
								start_time: "11 AM",
								duration: 120)
				
				visit edit_rehearsal_path(r3)
		  	select e1.full_name, from: "Invitees"
				click_button 'Update'
		
				should have_selector('div.alert-warning', text: "people are double booked")
				should have_selector('div.alert-warning', text: e1.full_name)
				should_not have_selector('div.alert-warning', text: e2.full_name)
				should_not have_selector('div.alert-warning', text: e3.full_name)
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
								duration: 300)
				FactoryGirl.create(:invitation, event: r_5hr, employee: e1)
				
				r = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc2,
								piece: piece,
								start_date: Time.zone.today,
								start_time: "2 PM",
								duration: 90)
				
				visit edit_rehearsal_path(r)
		  	select e1.full_name, from: "Invitees"
				click_button 'Update'
				
				should have_selector('div.alert-warning', text: "over their rehearsal limit")
				should have_selector('div.alert-warning', text: "hrs/day")
				should have_selector('div.alert-warning', text: e1.full_name)
			end
			
			it "when AGMA Dancer has exceeded their max rehearsal hours per week" do
				log_in
				loc = FactoryGirl.create(:location, account: current_account)
				loc2 = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account, role: 'AGMA Dancer')
				
				date = Date.new(2013,1,7)
				for i in 0..4 do
					r_6hr = FactoryGirl.create(:rehearsal, account: current_account,
									location: loc,
									piece: piece,
									start_date: date + i.days,
									start_time: "9 AM",
									duration: 360)
					FactoryGirl.create(:invitation, event: r_6hr, employee: e1)
				end
				
				r = FactoryGirl.create(:rehearsal, account: current_account,
								location: loc2,
								piece: piece,
								start_date: date + 5.days,
								start_time: "3 PM",
								duration: 30)
				
				visit edit_rehearsal_path(r)
		  	select e1.full_name, from: "Invitees"
				click_button 'Update'
				
				should have_selector('div.alert-warning', text: "over their rehearsal limit")
				should have_selector('div.alert-warning', text: "hrs/week")
				should have_selector('div.alert-warning', text: e1.full_name)
			end
		end
	end
end
