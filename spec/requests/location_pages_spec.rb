require 'spec_helper'

describe "Location Pages:" do
	subject { page }
  
  context "#index" do
  	it "has correct title" do
  		log_in
  		click_link "Setup"
	  	click_link "Locations"
	  	
	  	should have_selector('title', text: 'Locations')
		  should have_selector('h1', text: 'Locations')
		end
		
		it "has correct Navigation" do
			log_in
	  	visit locations_path
	
			should have_selector('li.active', text: 'Setup')
			should have_selector('li.active', text: 'Locations')
		end
		
		it "has correct Active/Inactive/All filter highlighting" do
			log_in
			
	  	visit locations_path
			should have_selector('a.active', text: 'All')
			
			click_link "Inactive"
			should have_selector('a.active', text: 'Inactive')
			
			click_link "All"
			should have_selector('a.active', text: 'All')
			
			click_link "Active"
			should have_selector('a.active', text: 'Active')
			
			visit locations_path(status: "invalid")
			should have_selector('a.active', text: 'All')
		end
		
		it "without records" do
			log_in
	  	visit locations_path
	  	
	    should have_selector('p', text: 'To begin')
			should_not have_selector('td')
			should_not have_selector('div.pagination')
		end
	  
		it "lists active records by default" do
			log_in
			4.times { FactoryGirl.create(:location, account: current_account) }
			4.times { FactoryGirl.create(:location_inactive, account: current_account) }
			visit locations_path(per_page: 3)
	
			should have_selector('th', text: "Name")
			should have_selector('th', text: "Status")
			should have_selector('div.pagination')
			
			Location.active.paginate(page: 1, per_page: 3).each do |location|
				should have_selector('td', text: location.name)
				should have_selector('td', text: 'Active')
				should_not have_selector('td', text: 'Inactive')
				
				should have_link('Edit', href: edit_location_path(location))
				should have_link('Inactivate', href: inactivate_location_path(location))
				should have_link('Delete', href: location_path(location))
	    end
		end
		
		it "can filter for inactive records" do
			log_in
			4.times { FactoryGirl.create(:location, account: current_account) }
			4.times { FactoryGirl.create(:location_inactive, account: current_account) }
			visit locations_path
			click_link "Inactive"
	
			should have_selector('th', text: "Name")
			should have_selector('th', text: "Status")
			
			Location.inactive.each do |location|
				should have_selector('td', text: location.name)
				should_not have_selector('td', text: 'Active')
				should have_selector('td', text: 'Inactive')
				
				should have_link('Edit', href: edit_location_path(location))
				should have_link('Inactivate', href: inactivate_location_path(location))
				should have_link('Delete', href: location_path(location))
	    end
		end
		
		it "can filter for all records" do
			log_in
			4.times { FactoryGirl.create(:location, account: current_account) }
			4.times { FactoryGirl.create(:location_inactive, account: current_account) }
			visit locations_path
			click_link "All"
	
			should have_selector('th', text: "Name")
			should have_selector('th', text: "Status")
			
			Location.all.each do |location|
				should have_selector('td', text: location.name)
				should have_selector('td', text: 'Active')
				should have_selector('td', text: 'Inactive')
				
				should have_link('Edit', href: edit_location_path(location))
				should have_link('Inactivate', href: inactivate_location_path(location))
				should have_link('Delete', href: location_path(location))
	    end
		end
		
		it "has links for Super Admin" do
			log_in
			FactoryGirl.create(:location, account: current_account)
			visit locations_path
	
			should have_link('Add Location')
			should have_link('Edit')
			should have_link('Inactivate')
			should have_link('Delete')
		end
		
		it "does not have links for Employee" do
			log_in_employee
			FactoryGirl.create(:location, account: current_account)
			visit locations_path
	
			should_not have_link('Add Location')
			should_not have_link('Edit')
			should_not have_link('Inactivate')
			should_not have_link('Delete')
		end
		
		it "has links for Administrator" do
			log_in_admin
			FactoryGirl.create(:location, account: current_account)
			visit locations_path
	
			should have_link('Add Location')
			should have_link('Edit')
			should have_link('Inactivate')
			should_not have_link('Delete')
		end
	end
	
	context "#inactivate" do
		it "changes location status to inactive" do
			log_in
			location = FactoryGirl.create(:location, account: current_account, name: 'Inactivate Test')
			visit locations_path
			click_link "inactivate_#{location.id}"
				
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Locations')
				
			click_link 'Active'
			should_not have_content(location.name)
				
			click_link 'Inactive'
			should have_content(location.name)
		end
	end
	
	context "#activate" do
		it "changes location status to active" do
			log_in
			location = FactoryGirl.create(:location_inactive, account: current_account, name: 'Activate Test')
			visit locations_path
			click_link 'Inactive'
			click_link "activate_#{location.id}"
			
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Locations')
			
			click_link 'Inactive'
			should_not have_content(location.name)
			
			click_link 'Active'
			should have_content(location.name)
		end
	end

	context "#new" do
		it "has correct title" do
			log_in
			click_link "Setup"
	  	click_link "Locations"
	  	click_link "Add Location"
	
			should have_selector('title', text: 'Add Location')
			should have_selector('h1', text: 'Add Location')
		end
		
		it "has correct Navigation" do
			log_in
	  	visit new_location_path
	
			should have_selector('li.active', text: 'Setup')
			should have_selector('li.active', text: 'Locations')
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				visit new_location_path
				click_button 'Create'
		
				should have_selector('div.alert-danger')
			end
			
			it "doesn't create Location" do
				log_in
				visit new_location_path
		
				expect { click_button 'Create' }.not_to change(Location, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Location" do
				log_in
				visit new_location_path
		  	
		  	new_name = Faker::Lorem.word
				fill_in "Name", with: new_name
				click_button 'Create'
		
				should have_selector('div.alert-success')
				should have_selector('title', text: 'Locations')
				should have_content(new_name)
			end
		end
	end

	context "#edit" do
		it "has correct title" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			click_link "Setup"
			click_link "Locations"
	  	click_link "Edit"
	  	
	  	should have_selector('title', text: 'Edit Location')
			should have_selector('h1', text: 'Edit Location')
		end
		
		it "has correct Navigation" do
			log_in
	  	location = FactoryGirl.create(:location, account: current_account)
	  	visit edit_location_path(location)
	
			should have_selector('li.active', text: 'Setup')
			should have_selector('li.active', text: 'Locations')
		end
		
	  it "record with error" do
	  	log_in
	  	location = FactoryGirl.create(:location, account: current_account)
	  	visit edit_location_path(location)
	  	fill_in "Name", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-danger')
		end
	
		it "with bad record in URL shows 'Record Not Found' error" do
			pending
			log_in
			visit edit_location_path(0)
	
			should have_content('Record Not Found')
		end
		
		it "record with wrong account shows 'Record Not Found' error" do
			pending
			log_in
			location_wrong_account = FactoryGirl.create(:location)
			visit edit_location_path(location_wrong_account)
	
			should have_content('Record Not Found')
		end
	 
		it "record with valid info saves location" do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			new_name = Faker::Lorem.word
			visit locations_path
			click_link "edit_#{location.id}"
			fill_in "Name", with: new_name
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Locations')
			should have_content(new_name)
		end
	end
	
	context "#destroy" do
		it "deletes the record" do
	  	log_in
			location = FactoryGirl.create(:location, account: current_account)
			visit locations_path
			click_link "delete_#{location.id}"
			
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Locations')
			
			click_link 'All'
			should_not have_content(location.name)
		end
	end
end
