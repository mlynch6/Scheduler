require 'spec_helper'

describe "Warnings Report Pages:" do
	subject { page }
	
  context "#show" do
		before do
  		log_in
  		click_link "Reports"
	  	click_link "Warnings"
		end
		
  	it "has correct title" do	
	  	should have_title 'Warnings Report'
		  should have_selector 'h1', text: 'Warnings Report'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Reports'
			should have_selector 'li.active', text: 'Warnings'
		end
		
		it "without warnings" do
			fill_in "start_date", with: '1/1/2014'
			fill_in "end_date", with: '1/1/2014'
			click_button 'Generate'
			
			should have_content 'No warnings found'
		end
	  
		context "shows warnings for Rehearsal Week: Max Hours/Day" do
			before do
				@start_date = Date.new(2014,1,1)
				@end_date = @start_date + 1.day
				
				@contract = current_account.agma_contract
				@contract.rehearsal_max_hrs_per_day = 6
				@contract.save
				
				@artist = FactoryGirl.create(:person, :artist, account: current_account)
				@rehearsal = FactoryGirl.create(:rehearsal, account: current_account)
				@event = FactoryGirl.create(:event, account: current_account,
							schedulable: @rehearsal,
							start_date: @start_date,
							duration: 390)
				FactoryGirl.create(:invitation, account: current_account, event: @event, person: @artist)
				
				click_link "Warnings"
				fill_in "start_date", with: '1/1/2014'
				fill_in "end_date", with: '1/2/2014'
				click_button 'Generate'
			end
			
			it "has correct table headers" do
				should have_selector 'th', text: "Artist Over Maximum Rehearsal Hours in a Day"
			end
			
			it "has warning shown" do
				should have_selector 'td', text: '01/01/2014'
				should have_selector 'td', text: "#{@artist.full_name} is over the maximum rehearsal allowance"
			end
		end
		
		context "shows warnings for Rehearsal Week: Max Hours/Week" do
			before do
				@start_date = Date.new(2014,1,1)
				@end_date = @start_date + 1.week
				
				@contract = current_account.agma_contract
				@contract.rehearsal_max_hrs_per_week = 6
				@contract.save
				
				@artist = FactoryGirl.create(:person, :artist, account: current_account)
				@rehearsal = FactoryGirl.create(:rehearsal, account: current_account)
				@event = FactoryGirl.create(:event, account: current_account,
							schedulable: @rehearsal,
							start_date: @start_date,
							duration: 390)
				FactoryGirl.create(:invitation, account: current_account, event: @event, person: @artist)
				
				click_link "Warnings"
				fill_in "start_date", with: '1/1/2014'
				fill_in "end_date", with: '1/2/2014'
				click_button 'Generate'
			end
			
			it "has correct table headers" do
				should have_selector 'th', text: "Artist Over Maximum Rehearsal Hours in a Week"
			end
			
			it "has warning shown" do
				should have_selector 'td', text: '12/30/2013 - 01/05/2014'
				should have_selector 'td', text: "#{@artist.full_name} is over the maximum rehearsal allowance"
			end
		end
		
		context "shows warnings for Company Class: Class Break" do
			pending
		end
		
		context "shows warnings for Costume Fitting: XX" do
			pending
		end
		
		context "shows warnings for Location Double Booked" do
			pending
		end
		
		context "shows warnings for Artist Double Booked" do
			pending
		end
	end
end
