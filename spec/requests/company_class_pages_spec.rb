require 'spec_helper'

describe "CompanyClass Pages:" do
	subject { page }
  
  context "#new" do
  	it "has correct title" do
			log_in
	  	visit events_path
	  	click_link 'New Company Class'
	  	
	  	should have_selector('title', text: 'New Company Class')
		  should have_selector('h1', text: 'New Company Class')
		end
		
		it "has only active Locations in dropdown" do
			log_in
			FactoryGirl.create(:location, account: current_account, name: 'Location A')
			FactoryGirl.create(:location_inactive, account: current_account, name: 'Location B')
			visit new_company_class_path
  		
			should have_selector('option', text: 'Location A')
			should_not have_selector('option', text: 'Location B')
		end
		
		it "has only active Employees in dropdown" do
			log_in
			FactoryGirl.create(:employee, account: current_account, last_name: 'Parker', first_name: 'Peter')
			FactoryGirl.create(:employee_inactive, account: current_account, last_name: 'Kent', first_name: 'Clark')
			visit new_company_class_path
  		
			should have_selector('option', text: 'Peter Parker')
			should_not have_selector('option', text: 'Clark Kent')
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				visit new_company_class_path
		  	click_button 'Create'
		
				should have_selector('div.alert-error')
			end
			
			it "doesn't create Company Class" do
				log_in
				visit events_path
	  		click_link 'New Company Class'
		
				expect { click_button 'Create' }.not_to change(CompanyClass, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Company Class without Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				visit events_path
	  		click_link 'New Company Class'
	  		
		  	fill_in "Title", with: "Test Company Class"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2013"
		  	fill_in 'From', with: "9AM"
		  	fill_in 'To', with: "10:30AM"
		  	click_button 'Create'
		
				should have_selector('title', text: 'Events')
				
				should have_selector('div.companyClass')
				should have_content("Test Company Class")
				should have_content(location.name)
				should have_content("9:00 AM")
				should have_content("10:30 AM")
				should have_content("0 invitees")
			end
			
			it "creates new Company Class with Invitees" do
				log_in
				location = FactoryGirl.create(:location, account: current_account)
				piece = FactoryGirl.create(:piece, account: current_account)
				e1 = FactoryGirl.create(:employee, account: current_account)
				visit events_path
	  		click_link 'New Company Class'
	  		
		  	fill_in "Title", with: "Test Company Class"
		  	select location.name, from: "Location"
		  	fill_in 'Date', with: "01/31/2013"
		  	fill_in 'From', with: "9AM"
		  	fill_in 'To', with: "10:30AM"
		  	select e1.full_name, from: "Invitees"
				click_button 'Create'
		
				should have_selector('title', text: 'Events')
				
				should have_selector('div.companyClass')
				should have_content("Test Company Class")
				should have_content(location.name)
				should have_content("9:00 AM")
				should have_content("10:30 AM")
				should have_content("1 invitee")
			end
		end
	end
	
	context "#show" do
		pending
	end
	
	context "#edit" do
		pending
	end
end
