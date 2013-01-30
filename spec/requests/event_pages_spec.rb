require 'spec_helper'

describe "Event Pages:" do
	subject { page }
  
  context "#index" do
  	it "has correct title & headers" do
			log_in
	  	visit events_path
	  	
	  	should have_selector('title', text: 'Events')
		  should have_selector('h1', text: 'Events')
		  should have_selector('h2', text: Time.zone.today.to_s(:long))
		  should have_content(Time.zone.today.strftime('%A'))
		end
		
		it "without records" do
			log_in
	  	visit events_path
	  	
			should_not have_selector('div.event')
		end
	  
		it "lists records" do
			log_in
			loc1 = FactoryGirl.create(:location, account: current_account)
			loc2 = FactoryGirl.create(:location, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			2.times { FactoryGirl.create(:rehearsal,
										account: current_account,
										location: loc1,
										piece: piece) }
			2.times { FactoryGirl.create(:rehearsal,
										account: current_account,
										location: loc2,
										piece: piece) }
			visit events_path
	
			should have_selector('div.Rehearsal')
			Event.for_daily_calendar(Time.zone.today).each do |event|
				should have_selector('div', text: 'R')
				should have_selector('div', text: event.title)
				should have_selector('div', text: event.location.name)
				should have_selector('div', text: event.piece.name)
				should have_content(event.start_at.to_s(:hr12))
				should have_content(event.end_at.to_s(:hr12))
	    end
		end
		
		it "doesn't have links for Employee" do
			log_in_employee
			location = FactoryGirl.create(:location, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			FactoryGirl.create(:rehearsal, account: current_account, location: location, piece: piece)
			visit events_path
	
			should_not have_link('New Rehearsal', href: new_rehearsal_path)
		end
		
		it "has links for Administrator" do
			log_in_admin
			location = FactoryGirl.create(:location, account: current_account)
			piece = FactoryGirl.create(:piece, account: current_account)
			FactoryGirl.create(:rehearsal, account: current_account, location: location, piece: piece)
			visit events_path
	
			should have_link('New Rehearsal', href: new_rehearsal_path)
		end
		
	end
end
