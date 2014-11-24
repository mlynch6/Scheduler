require 'spec_helper'

describe "Calendar Pages:" do
	subject { page }
  
  context "#index", js: true do
		pending
		# before do
# 			log_in
# 			click_link 'Calendar'
# 		end
#
# 		it "has correct title & headers" do
# 			should have_title 'Calendar'
# 			should have_selector 'h1', text: 'Calendar'
# 		  should have_selector 'h2', text: Time.zone.today.strftime('%B %-d, %Y')
# 		  should have_content Time.zone.today.strftime('%A')
# 		end
#
# 		it "has correct Navigation" do
# 			should have_selector 'li.active', text: 'Calendar'
# 			should have_selector 'li.active', text: 'Today'
# 		end
#
# 		it "without records" do
# 			should_not have_selector 'div.event'
# 		end
#
# 	  context "lists records" do
# 			before do
# 				@location = FactoryGirl.create(:location, account: current_account)
# 			end
#
# 			it "with type of Event" do
# 				FactoryGirl.create(:event,
# 						account: current_account,
# 						location: @location,
# 						title: 'My Event',
# 						start_date: Time.zone.today,
# 						start_time: '9:15AM')
# 				visit events_path
#
# 				should have_selector 'div', text: '9:15 AM'
# 				should have_selector 'div', text: 'My Event'
# 				should have_selector 'div', text: @location.name
# 			end
#
# 			it "with type of Company Class" do
# 				FactoryGirl.create(:company_class,
# 						account: current_account,
# 						location: @location,
# 						title: 'My Company Class',
# 						start_date: Time.zone.today,
# 						start_time: '9:15AM')
# 				visit events_path
#
# 				should have_selector 'div', text: '9:15 AM'
# 				should have_selector 'div', text: 'My Company Class'
# 				should have_selector 'div', text: @location.name
# 			end
#
# 			it "with type of Costume Fitting" do
# 				FactoryGirl.create(:costume_fitting,
# 						account: current_account,
# 						location: @location,
# 						title: 'My Costume Fitting',
# 						start_date: Time.zone.today,
# 						start_time: '9:15AM')
# 				visit events_path
#
# 				should have_selector 'div', text: '9:15 AM'
# 				should have_selector 'div', text: 'My Costume Fitting'
# 				should have_selector 'div', text: @location.name
# 			end
#
# 			it "with type of Rehearsal" do
# 				piece = FactoryGirl.create(:piece, account: current_account)
# 				FactoryGirl.create(:rehearsal,
# 						account: current_account,
# 						location: @location,
# 						piece: piece,
# 						title: 'My Rehearsal',
# 						start_date: Time.zone.today,
# 						start_time: '9:15AM')
# 				visit events_path
#
# 				should have_selector 'div', text: '9:15 AM'
# 				should have_selector 'div', text: 'My Rehearsal'
# 				should have_selector 'div', text: @location.name
# 			end
# 		end
#
# 		describe "with date in URL" do
# 			it "navigates to correct day" do
# 				visit events_path+"/2014/1/1"
#
# 				should have_selector 'h2', text: "January 1, 2014"
# 			end
# 		end
#
# 		it "has links for Super Admin" do
# 			should have_link 'Add Company Class', :visible => false
# 			should have_link 'Add Rehearsal', :visible => false
# 			should have_link 'Add Costume Fitting', :visible => false
# 			should have_link 'Add Event', :visible => false
# 		end
	end
end
