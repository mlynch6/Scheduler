require 'spec_helper'

describe "Rehearsal Pages:" do
	subject { page }
  
  context "#index" do
		before do
  		log_in
  		click_link "Calendar"
	  	click_link "Rehearsals"
		end
		
  	it "has correct title" do	
	  	should have_title 'Rehearsals'
		  should have_selector 'h1', text: 'Rehearsals'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Rehearsals'
		end
		
		it "has correct table headers" do
			should have_selector 'th', text: "Title"
			should have_selector 'th', text: "Piece"
			should have_selector 'th', text: "Date"
			should have_selector 'th', text: "Location"
		end
		
		it "without records" do
			should have_selector 'td', text: 'None found'
			should_not have_selector 'div.pagination'
		end
	  
		it "lists records" do
			4.times do
				rehearsal = FactoryGirl.create(:rehearsal, account: current_account)
				FactoryGirl.create(:event, :with_location, account: current_account, schedulable: rehearsal)
			end
			
			visit schedule_rehearsals_path(per_page: 3)
			should have_selector 'div.pagination'
			
			#check records without pagination because of sort order difference
			visit schedule_rehearsals_path
			
			Account.current_id = current_account.id
			records = Rehearsal.all
			records.count.should > 0
			records.each do |rehearsal|
				should have_selector 'td', text: rehearsal.title
				should have_selector 'td', text: rehearsal.piece.name
				should have_selector 'td', text: rehearsal.start_date
				should have_selector 'td', text: rehearsal.time_range
				should have_selector 'td', text: rehearsal.location.name
				
				should have_link rehearsal.title, href: schedule_rehearsal_path(rehearsal)
				should have_link 'Delete', href: schedule_rehearsal_path(rehearsal)
	    end
		end
		
		describe "can search" do
			before do
				4.times do
					rehearsal = FactoryGirl.create(:rehearsal, account: current_account)
					FactoryGirl.create(:event, :with_location, account: current_account, schedulable: rehearsal)
				end
				@piece = FactoryGirl.create(:piece, account: current_account)
				@season = FactoryGirl.create(:season, account: current_account)
				@location = FactoryGirl.create(:location, account: current_account)
				@rhino = FactoryGirl.create(:rehearsal, account: current_account, title: 'My Rhino Rehearsal', season: @season, piece: @piece)
				FactoryGirl.create(:event, :with_location, account: current_account, location: @location, schedulable: @rhino)
				visit schedule_rehearsals_path
			end
			
			it "on Title" do
				fill_in "Title", with: 'Rhino'
				click_button 'Search'
			
				should have_selector 'tr', count: 2
				should have_selector 'td', text: @rhino.title
			end
			
			it "on Piece" do
				select @piece.name, from: 'piece'
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
			rehearsal = FactoryGirl.create(:rehearsal, account: current_account)
			FactoryGirl.create(:event, :with_location, account: current_account, schedulable: rehearsal)
			visit schedule_rehearsals_path
	
			should have_link 'Add Rehearsal'
			should have_link rehearsal.title
			should have_link 'Delete'
		end
	end
	
  context "#new" do
		before do
			log_in
			@season = FactoryGirl.create(:season, account: current_account)
			click_link 'Calendar'
			click_link 'Rehearsals'
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
		
		it "has correct fields on form" do
	    should have_field 'Title'
			should have_select 'Piece'
			should have_select 'Scene'
			should have_select 'Location'
			should have_field 'Date'
			should have_field 'Start Time'
			should have_field 'Duration'
			should have_field 'Description'
			should have_link 'Cancel', href: schedule_rehearsals_path
		end
		
		context "with error" do
			it "shows error message" do
				click_button 'Schedule'
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Rehearsal" do
				expect { click_button 'Schedule' }.not_to change(Rehearsal, :count)
			end
			
			it "doesn't create Event" do
				expect { click_button 'Schedule' }.not_to change(Event, :count)
			end
		end
		
		context "with valid info" do
			before do
				@location = FactoryGirl.create(:location, account: current_account)
				@season = FactoryGirl.create(:season, account: current_account)
				@piece = FactoryGirl.create(:piece, account: current_account)
				visit new_schedule_rehearsal_path
	  		
				fill_in "Title", with: "My Rehearsal"
				select @piece.name, from: 'Piece'
				fill_in 'Date', with: "01/31/2013"
				fill_in 'Start Time', with: "10:15AM"
				fill_in 'Duration', with: 60
			end
			
			it "creates new Rehearsal without Location/Scene" do
				click_button 'Schedule'
				
				should have_selector 'div.alert-success'
				click_link 'Overview'
				
				should have_content 'My Rehearsal'
				should have_content @piece.name
				should have_content 'January 31, 2013'
				should have_content '10:15 AM to 11:15 AM'
				should have_content 'TBD'
			end
			
			it "creates new Rehearsal with Location" do
				select @location.name, from: "Location"
				click_button 'Schedule'
				
				should have_selector 'div.alert-success'
				click_link 'Overview'
				
				should have_content 'My Rehearsal'
				should have_content @piece.name
				should have_content 'January 31, 2013'
				should have_content '10:15 AM to 11:15 AM'
				should have_content @location.name
			end
			
			it "displays 'Edit Invitee' view after save" do
				click_button 'Schedule'
				
				should have_selector 'div.alert-success'
				should have_title 'My Rehearsal | Edit Invitees'
			end
		end
		
		it "displays Scene field when selected Piece has scenes", js: true do
#		pending "Works in GUI"
			@piece = FactoryGirl.create(:piece, account: current_account)
			@scene = FactoryGirl.create(:scene, account: current_account, piece: @piece)
			visit new_schedule_rehearsal_path
			
			select_from_chosen @piece.name, from: 'Piece'
			
			should have_select "Scene"
		end
		
		it "hides Scene field when selected Piece doesn't have scenes", js: true do
			@piece = FactoryGirl.create(:piece, account: current_account)
			visit new_schedule_rehearsal_path
			
			select_from_chosen @piece.name, from: 'Piece'
			
			should_not have_select 'Scene'
		end
	end
	
	context "#edit" do
		before do
			log_in
			@rehearsal = FactoryGirl.create(:rehearsal, account: current_account)
			@event = FactoryGirl.create(:event, :with_location, account: current_account, schedulable: @rehearsal)
			click_link 'Calendar'
			click_link 'Rehearsals'
	  	click_link @rehearsal.title
			click_link 'Edit'
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
		
		it "has correct fields on form" do
	    should have_field 'Title'
			should have_select 'Piece'
			should have_select 'Scene'
			should have_select 'Location'
			should have_field 'Date'
			should have_field 'Start Time'
			should have_field 'Duration'
			should have_field 'Description'
			should have_link 'Cancel', href: schedule_rehearsal_path(@rehearsal)
		end
		
	  it "record with error" do
	  	fill_in "Title", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "record with valid info saves rehearsal" do
			new_title = Faker::Lorem.word
			fill_in "Title", with: new_title
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Rehearsals'
			should have_content new_title
		end
	end
	
	context "#show" do
		before do
			log_in
			@rehearsal = FactoryGirl.create(:rehearsal, account: current_account)
			@event = FactoryGirl.create(:event, :with_location, account: current_account, schedulable: @rehearsal)
			click_link 'Calendar'
			click_link 'Rehearsals'
	  	click_link @rehearsal.title
		end
		
  	it "has correct title" do
	  	should have_title @rehearsal.title
		  should have_selector 'h1', text: @rehearsal.title
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Calendar'
			should have_selector 'li.active', text: 'Rehearsal'
			should have_selector 'li.active', text: 'Overview'
		end
		
		it "displays correct data" do
			should have_content @rehearsal.title
			should have_content @rehearsal.piece.name
			should have_content @event.location.name
			should have_content @rehearsal.comment
			should have_content @rehearsal.start_date
			should have_content "9:15 AM to 10:15 AM"
			should have_content "1 hour"
		end
		
		it "displays correct break" do
			@break60 = FactoryGirl.create(:rehearsal_break, 
								agma_contract: current_account.agma_contract,
								duration_min: 60,
								break_min: 5)
			visit schedule_rehearsal_path(@rehearsal)
			
			should have_content @rehearsal.break_time_range
			should have_content "5 minutes"
		end
		
		it "hides break when N/A" do
			should_not have_content "Break"
		end
		
		it "has links for Super Admin" do
			should have_link 'Edit'
		end
	end
	
	context "#destroy" do
		before do
			log_in
			@rehearsal = FactoryGirl.create(:rehearsal, account: current_account)
			@event = FactoryGirl.create(:event, :with_location, account: current_account, schedulable: @rehearsal)
			visit schedule_rehearsals_path
			click_link "delete_#{@rehearsal.id}"
		end
		
		it "deletes the record" do
			should have_selector 'div.alert-success'
			should have_title 'Rehearsals'
			
			should_not have_content @rehearsal.title
		end
	end
end
