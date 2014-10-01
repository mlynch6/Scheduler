require 'spec_helper'

describe "CostumeFitting Pages:" do
	subject { page }
  
  context "#index" do
		before do
  		log_in
  		click_link "Calendar"
	  	click_link "Costume Fittings"
		end
		
  	it "has correct title" do	
	  	should have_title 'Costume Fittings'
		  should have_selector 'h1', text: 'Costume Fittings'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Costume Fittings'
		end
		
		it "has correct table headers" do
			should have_selector 'th', text: "Title"
			should have_selector 'th', text: "Date"
			should have_selector 'th', text: "Location"
		end
		
		it "without records" do
			should have_selector 'td', text: 'None found'
			should_not have_selector 'div.pagination'
		end
	  
		it "lists records" do
			4.times do
				fitting = FactoryGirl.create(:costume_fitting, account: current_account)
				FactoryGirl.create(:event, :with_location, account: current_account, schedulable: fitting)
			end
			visit schedule_costume_fittings_path(per_page: 3)
			
			should have_selector 'div.pagination'
			CostumeFitting.paginate(page: 1, per_page: 3).each do |fitting|
				should have_selector 'td', text: fitting.title
				should have_selector 'td', text: fitting.start_date
				should have_selector 'td', text: fitting.time_range
				should have_selector 'td', text: fitting.location.name
				
				should have_link fitting.name, href: edit_schedule_costume_fitting_path(fitting)
				should have_link 'Delete', href: schedule_costume_fitting_path(fitting)
	    end
		end
		
		describe "can search" do
			before do
				4.times do
					fitting = FactoryGirl.create(:costume_fitting, account: current_account)
					FactoryGirl.create(:event, :with_location, account: current_account, schedulable: fitting)
				end
				@season = FactoryGirl.create(:season, account: current_account)
				@location = FactoryGirl.create(:location, account: current_account)
				@rhino = FactoryGirl.create(:costume_fitting, account: current_account, title: 'My Rhino Fitting', season: @season)
				FactoryGirl.create(:event, :with_location, account: current_account, location: @location, schedulable: @rhino)
				visit schedule_costume_fittings_path
			end
			
			it "on Title" do
				fill_in "Title", with: 'Rhino'
				click_button 'Search'
			
				should have_selector 'tr', count: 2
				should have_selector 'td', text: @rhino.title
			end
			
			it "on Season" do	
				select @season.name, from: 'season'
				click_button 'Search'
			
				should have_selector 'tr', count: 2
				should have_selector 'td', text: @rhino.title
			end
		
			it "on Location" do
				select @location.name, from: 'loc'
				click_button 'Search'
			
				should have_selector 'tr', count: 2
				should have_selector 'td', text: @rhino.title
			end
		end
		
		it "has links for Super Admin" do
			fitting = FactoryGirl.create(:costume_fitting, account: current_account)
			FactoryGirl.create(:event, :with_location, account: current_account, schedulable: fitting)
			visit schedule_costume_fittings_path
	
			should have_link 'Add Costume Fitting'
			should have_link fitting.title
			should have_link 'Delete'
		end
	end
	
  context "#new" do
		before do
			log_in
			click_link 'Calendar'
			click_link 'Costume Fittings'
			click_link 'Add Costume Fitting'
		end
		
		it "has correct title" do
			should have_title 'Add Costume Fitting'
		  should have_selector 'h1', text: 'Costume Fittings'
			should have_selector 'h1 small', text: 'Add'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Costume Fittings'
		end
		
		it "has correct fields on form" do
	    should have_field 'Title'
			should have_field 'Location'
			should have_field 'Season'
			should have_field 'Date'
			should have_field 'Start Time'
			should have_field 'Duration'
			should have_field 'Description'
			should have_link 'Cancel', href: schedule_costume_fittings_path
		end
		
		context "with error" do
			it "shows error message" do
				click_button 'Schedule'
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Costume Fitting" do
				expect { click_button 'Schedule' }.not_to change(CostumeFitting, :count)
			end
			
			it "doesn't create Event" do
				expect { click_button 'Schedule' }.not_to change(Event, :count)
			end
		end
		
		context "with valid info" do
			before do
				@location = FactoryGirl.create(:location, account: current_account)
				@season = FactoryGirl.create(:season, account: current_account)
				visit new_schedule_costume_fitting_path
	  		
				fill_in "Title", with: "Costume Fitting for Nutcracker"
				select @season.name, from: 'Season'
				fill_in 'Date', with: "01/31/2013"
				fill_in 'Start Time', with: "10:15AM"
				fill_in 'Duration', with: 60
			end
			
			it "creates new Costume Fitting without Location" do
				click_button 'Schedule'
				
				should have_selector 'div.alert-success'
				should have_title 'Costume Fittings'
				should have_content 'Costume Fitting for Nutcracker'
				should have_content '01/31/2013'
				should have_content '10:15 AM to 11:15 AM'
				should have_content 'TBD'
			end
			
			it "creates new Costume Fitting with Location" do
				select @location.name, from: "Location"
				click_button 'Schedule'
				
				should have_selector 'div.alert-success'
				should have_title 'Costume Fittings'
				should have_content 'Costume Fitting for Nutcracker'
				should have_content '01/31/2013'
				should have_content '10:15 AM to 11:15 AM'
				should have_content @location.name
			end
		end
	end
	
	context "#edit" do
		before do
			log_in
			@fitting = FactoryGirl.create(:costume_fitting, account: current_account)
			@event = FactoryGirl.create(:event, :with_location, account: current_account, schedulable: @fitting)
			click_link 'Calendar'
			click_link 'Costume Fittings'
	  	click_link @fitting.title
		end
		
		it "has correct title" do	
	  	should have_title 'Edit Costume Fitting'
			should have_selector 'h1', text: 'Costume Fittings'
			should have_selector 'h1 small', text: 'Edit'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Costume Fittings'
		end
		
		it "has correct fields on form" do
	    should have_field 'Title'
			should have_field 'Location'
			should have_field 'Season'
			should have_field 'Date'
			should have_field 'Start Time'
			should have_field 'Duration'
			should have_field 'Description'
			should have_link 'Cancel', href: schedule_costume_fittings_path
		end
		
	  it "record with error" do
	  	fill_in "Title", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "record with valid info saves location" do
			new_title = Faker::Lorem.word
			fill_in "Title", with: new_title
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Costume Fittings'
			should have_content new_title
		end
	end
	
	context "#destroy" do
		before do
			log_in
			@fitting = FactoryGirl.create(:costume_fitting, account: current_account)
			@event = FactoryGirl.create(:event, :with_location, account: current_account, schedulable: @fitting)
			visit schedule_costume_fittings_path
			click_link "delete_#{@fitting.id}"
		end
		
		it "deletes the record" do
			should have_selector 'div.alert-success'
			should have_title 'Costume Fittings'
			
			should_not have_content @fitting.title
		end
	end
end
