require 'spec_helper'

describe "Location Pages:" do
	subject { page }
  
  context "#index" do
		before do
  		log_in
  		click_link "Setup"
	  	click_link "Locations"
		end
		
  	it "has correct title" do	
	  	should have_title 'Locations'
		  should have_selector 'h1', text: 'Locations'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Locations'
		end
		
		it "has correct table headers" do
			4.times { FactoryGirl.create(:location, account: current_account) }
			visit locations_path(per_page: 3)
			
			should have_selector 'th', text: "Name"
			should have_selector 'th', text: "Status"
			should have_selector 'div.pagination'
		end
		
		it "has correct Active/Inactive/All filter highlighting" do
			select "Inactive", from: 'status'
			click_button 'Search'
			should have_selector 'h1 small', text: 'Inactive'
			
			select "Active", from: 'status'
			click_button 'Search'
			should have_selector 'h1 small', text: 'Active'
			
			select "All", from: 'status'
			click_button 'Search'
			should have_selector 'h1 small', text: 'All'
			
			visit locations_path(status: "invalid")
			should have_selector 'h1 small', text: 'All'
		end
		
		it "without records" do
	    should have_selector 'p', text: 'To begin'
			should_not have_selector 'td'
			should_not have_selector 'div.pagination'
		end
	  
		it "lists active records by default" do
			4.times { FactoryGirl.create(:location, account: current_account) }
			4.times { FactoryGirl.create(:location, :inactive, account: current_account) }
			visit locations_path(per_page: 3)
			
			Location.active.paginate(page: 1, per_page: 3).each do |location|
				should have_selector 'td', text: location.name
				should have_selector 'td', text: 'Active'
				should_not have_selector 'td', text: 'Inactive'
				
				should have_link location.name, href: edit_location_path(location)
				should have_link 'Inactivate', href: inactivate_location_path(location)
				should have_link 'Delete', href: location_path(location)
	    end
		end
		
		describe "can search" do
			before do
				4.times { FactoryGirl.create(:location, account: current_account) }
				4.times { FactoryGirl.create(:location, :inactive, account: current_account) }
				@rhino = FactoryGirl.create(:location, account: current_account, name: 'My Rhino Studio')
				visit locations_path
			end
			
			it "for inactive records" do	
				select "Inactive", from: 'status'
				click_button 'Search'
			
				Location.inactive.each do |location|
					should have_selector 'td', text: location.name
					should_not have_selector 'td', text: 'Active'
					should have_selector 'td', text: 'Inactive'
				
					should have_link location.name, href: edit_location_path(location)
					should have_link 'Inactivate', href: inactivate_location_path(location)
					should have_link 'Delete', href: location_path(location)
		    end
			end
		
			it "for all records" do
				select "All", from: 'status'
				click_button 'Search'
			
				Location.all.each do |location|
					should have_selector 'td', text: location.name
					should have_selector 'td', text: 'Active'
					should have_selector 'td', text: 'Inactive'
				
					should have_link location.name, href: edit_location_path(location)
					should have_link 'Inactivate', href: inactivate_location_path(location)
					should have_link 'Delete', href: location_path(location)
		    end
			end
			
			it "on Name" do
				fill_in "query", with: 'Rhino'
				click_button 'Search'
			
				should have_selector 'tr', count: 2
				should have_selector 'td', text: @rhino.name
			end
		end
		
		it "has links for Super Admin" do
			location = FactoryGirl.create(:location, account: current_account)
			visit locations_path
	
			should have_link 'Add Location'
			should have_link location.name
			should have_link 'Inactivate'
			should have_link 'Delete'
		end
	end
	
	context "#inactivate" do
		before do
			log_in
			@location = FactoryGirl.create(:location, account: current_account)
			visit locations_path
			click_link "inactivate_#{@location.id}"
		end
		
		it "changes location status to inactive" do
			should have_selector 'div.alert-success'
			should have_title 'Locations'
				
			select "Active", from: 'status'
			click_button 'Search'
			should_not have_content @location.name
				
			select "Inactive", from: 'status'
			click_button 'Search'
			should have_content @location.name
		end
	end
	
	context "#activate" do
		before do
			log_in
			@location = FactoryGirl.create(:location, :inactive, account: current_account)
			visit locations_path
			select "Inactive", from: 'status'
			click_button 'Search'
			click_link "activate_#{@location.id}"
		end
		
		it "changes location status to active" do	
			should have_selector 'div.alert-success'
			should have_title 'Locations'
			
			select "Inactive", from: 'status'
			click_button 'Search'
			should_not have_content @location.name
			
			select "Active", from: 'status'
			click_button 'Search'
			should have_content @location.name
		end
	end

	context "#new" do
		before do
			log_in
			click_link "Setup"
	  	click_link "Locations"
	  	click_link "Add Location"
		end
		
		it "has correct title" do
			should have_title 'Add Location'
			should have_selector 'h1', text: 'Locations'
			should have_selector 'h1 small', text: 'Add'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Locations'
		end
		
		it "has correct fields on form" do
	    should have_field 'Name'
			should have_field 'Active'
			should have_field 'Inactive'
			should have_link 'Cancel', href: locations_path
		end
		
		context "with error" do
			it "shows error message" do
				click_button 'Create'
		
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Location" do
				expect { click_button 'Create' }.not_to change(Location, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Location" do
		  	new_name = Faker::Lorem.word
				fill_in "Name", with: new_name
				click_button 'Create'
		
				should have_selector 'div.alert-success'
				should have_title 'Locations'
				should have_content new_name
			end
		end
	end

	context "#edit" do
		before do
			log_in
			@location = FactoryGirl.create(:location, account: current_account)
			click_link "Setup"
			click_link "Locations"
	  	click_link @location.name
		end
		
		it "has correct title" do	
	  	should have_title 'Edit Location'
			should have_selector 'h1', text: 'Locations'
			should have_selector 'h1 small', text: 'Edit'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'Locations'
		end
		
		it "has correct fields on form" do
	    should have_field 'Name'
			should have_field 'Active'
			should have_field 'Inactive'
			should have_link 'Cancel', href: locations_path
		end
		
	  it "record with error" do
	  	fill_in "Name", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "record with valid info saves location" do
			new_name = Faker::Lorem.word
			fill_in "Name", with: new_name
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Locations'
			should have_content new_name
		end
	end
	
	context "#destroy" do
		before do
	  	log_in
			@location = FactoryGirl.create(:location, account: current_account)
			visit locations_path
			click_link "delete_#{@location.id}"
		end
		
		it "deletes the record" do
			should have_selector 'div.alert-success'
			should have_title 'Locations'
			
			select "All", from: 'status'
			click_button 'Search'
			should_not have_content @location.name
		end
	end
end
