require 'spec_helper'

describe "Event Series Pages:" do
	subject { page }
  
  context "#new" do
		before do
			log_in
			@location = FactoryGirl.create(:location, account: current_account, name: 'Loc1')
		  click_link 'Calendar'
			click_button 'Tools'
		  click_link 'Add Event'
		end
		
	  it "has correct title" do
		  should have_title 'Add Event'
		  should have_selector 'h1', text: 'Events'
			should have_selector 'h1 small', text: 'Add'
		end
		
		context "only shows applicable fields for Repeat tab", js: true do
			it "when Period is Never" do
				click_link "Repeat"
				should have_select 'Period', selected: "Never"
				should_not have_field 'End On'
			end
	  	
	  	it "when Period is Daily" do
				click_link "Repeat"
				select "Daily", from: 'Period'
				should have_field 'End On'
			end
			
			it "when Period is Weekly" do
				click_link "Repeat"
				select "Weekly", from: 'Period'
				should have_field 'End On'
			end
			
			it "when Period is Monthly" do
				click_link "Repeat"
				select "Monthly", from: 'Period'
				should have_field 'End On'
			end
			
			it "when Period is Yearly" do
				click_link "Repeat"
				select "Yearly", from: 'Period'
				should have_field 'End On'
			end
		end
		
		context "with error" do
			before do
				fill_in "Title", with: "Repeating Event"
				select @location.name, from: "Location"
				fill_in 'Date', with: "01/31/2013"
				fill_in 'Start Time', with: "10AM"
				fill_in 'Duration', with: 60
				click_link 'Repeat'
				select 'Daily', from: 'Period'
	  	end
	  	
			it "shows error message" do
				fill_in 'End On', with: "01/1/2013"
				click_button 'Create'
		
				should have_selector 'div.alert-danger'
				should have_content 'End Date must be after the Start Date'
			end
			
			it "doesn't create EventSeries" do
				expect { click_button 'Create' }.not_to change(EventSeries, :count)
			end
			
			it "doesn't create Event" do
				expect { click_button 'Create' }.not_to change(Event, :count)
			end
		end

		context "with valid info", js: true do
			before do
				log_in
				location = FactoryGirl.create(:location, account: current_account, name: 'Loc1')
				emp = FactoryGirl.create(:employee, account: current_account, first_name: 'Peter', last_name: 'Parker')
				visit new_event_path
				
				fill_in "Title", with: "Repeating Event"
				select location.name, from: "Location"
				fill_in 'Date', with: "01/01/2013"
				fill_in 'Start Time', with: "10:15AM"
				fill_in 'Duration', with: 60
		  	
				click_link 'Repeat'
				select 'Daily', from: 'Period'
				fill_in 'End On', with: "01/05/2013"
				click_button 'Create'
			end
	  	
			it "creates Series with multiple Events" do
				should have_selector 'div.alert-success'
				should have_title 'Calendar'
				
				(Date.new(2013,1,1)..Date.new(2013,1,5)).each do |dt|
					should have_content dt.strftime('%B %-d, %Y')
					should have_content "Repeating Event"
					should have_content "10:15 AM - 11:15 AM"
					
					find('.fc-button-next').click
				end
			end
		end
		
		context "with warnings" do
			it "shows warning when location is booked" do
				pending
				log_in
				location = FactoryGirl.create(:location, account: current_account, name: 'Loc1')
				event = FactoryGirl.create(:event, account: current_account,
										location: location,
										start_date: Date.new(2013, 1, 2),
										start_time: "10 AM",
										duration: 90)
				visit new_event_path
				
				fill_in "Title", with: "Repeating Event"
				select location.name, from: "Location"
				fill_in 'Date', with: "01/01/2013"
				fill_in 'Start Time', with: "10AM"
				fill_in 'Duration', with: 60
				click_link 'Repeat'
				select 'Daily', from: 'Period'
				fill_in 'End On', with: "01/05/2013"
				click_button 'Create'
		
				should have_selector 'div.alert-warning', text: "is double booked during this time"
				should have_selector 'div.alert-warning', text: location.name
			end
			
			it "shows warning when employee is double booked" do
				pending
			end
		end
	end
	
	context "#edit", js: true do
		before do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			Account.current_id = current_account.id
			series = FactoryGirl.create(:event_series, 
									account: current_account, 
									title: 'My Repeating',
									location_id: location.id,
									start_date: Date.new(2014,1,1),
									start_time: "11 AM",
									duration: 60,
									period: 'Daily',
									end_date: Date.new(2014,1,5))
		end
		
		it "has correct title" do
			visit events_path+'/2014/1/1'
			open_modal(".mash-event")
			click_link 'Edit'
	  	
			should have_title 'Edit Event'
			should have_selector 'h1', text: 'Events'
			should have_selector 'h1 small', text: 'Edit'
		end
		
		it "has correct Navigation" do
			visit events_path+'/2014/1/1'
			open_modal(".mash-event")
			click_link 'Edit'
	
			should have_selector 'li.active', text: 'Calendar'
		end
		
		describe "has correct Update options" do
			it "for first event in series" do
				visit events_path+'/2014/1/1'
				open_modal(".mash-event")
				click_link 'Edit'
				open_modal('button', text: 'Update')
				
				should have_button 'All'
				should have_button 'Only This Event'
			end
			
			it "for 2nd+ event in series" do
				visit events_path+'/2014/1/5'
				open_modal(".mash-event")
				click_link 'Edit'
				open_modal('button', text: 'Update')
				
				should have_button 'All Future Events'
				should have_button 'Only This Event'
			end
		end
		
		it "has Repeat fields populating correctly" do	  	
			visit events_path+'/2014/1/1'
			open_modal(".mash-event")
			click_link 'Edit'
			click_link 'Repeat'
	
			should have_select 'Period', selected: 'Daily'
			should have_field 'End On', with: '01/05/2014'
		end
		
		describe "when 'Only This Event' is selected" do
			it "updates the event" do
				visit events_path+'/2014/1/3'
				open_modal(".mash-event")
				click_link 'Edit'
		  	
				fill_in "Title", with: "Repeating UPDATED"
		  	
				open_modal('button', text: 'Update')
				click_button 'Only This Event'
				
				should have_selector 'div.alert-success'
				should have_content 'January 3, 2014'
				should have_content 'Repeating UPDATED'
			end
			
			it "does not update the other repeating events" do
				visit events_path+'/2014/1/3'
				open_modal(".mash-event")
				click_link 'Edit'
		  	
				fill_in "Title", with: "Repeating UPDATED"
		  	
				open_modal('button', text: 'Update')
				click_button 'Only This Event'
				
				should have_selector 'div.alert-success'
				
				visit events_path+'/2014/1/1'
				should have_content 'My Repeating'
				should_not have_content 'Repeating UPDATED'
				
				open_modal(".mash-event")
				should have_content 'Daily'
			end
			
			it "removes the event from the series" do
				visit events_path+'/2014/1/3'
				open_modal(".mash-event")
				click_link 'Edit'
		  	
				fill_in "Title", with: "Repeating UPDATED"
		  	
				open_modal('button', text: 'Update')
				click_button 'Only This Event'
				
				should have_selector 'div.alert-success'
				should have_content 'Repeating UPDATED'
				
				open_modal(".mash-event")
				should_not have_selector 'dtl-label', text: 'Repeat'
			end

			it "shows errors" do
				visit events_path+'/2014/1/3'
				open_modal(".mash-event")
				click_link 'Edit'
		  	
				fill_in "Title", with: ""
		  	
				open_modal('button', text: 'Update')
				click_button 'Only This Event'
				
				should have_selector 'div.alert-danger'
			end

			describe "shows warnings" do
				it "when location is double booked" do
					pending
				end
					
				it "shows warning when employee is double booked" do
					pending
				end
			end
		end
		
		describe "when 'All' is selected" do
			it "updates the all the events in the series" do
				visit events_path+'/2014/1/1'
				open_modal(".mash-event")
				click_link 'Edit'
		  	
				fill_in "Title", with: "Repeating UPDATED"
		  	
				open_modal('button', text: 'Update')
				click_button 'All'
				
				should have_selector 'div.alert-success'
				should have_content 'January 1, 2014'
				should have_content 'Repeating UPDATED'
				
				visit events_path+'/2014/1/2'
				should have_content 'Repeating UPDATED'
				
				visit events_path+'/2014/1/3'
				should have_content 'Repeating UPDATED'
				
				visit events_path+'/2014/1/4'
				should have_content 'Repeating UPDATED'
				
				visit events_path+'/2014/1/5'
				should have_content 'Repeating UPDATED'
			end

			it "shows errors" do
				visit events_path+'/2014/1/1'
				open_modal(".mash-event")
				click_link 'Edit'
		  	
				fill_in "Title", with: ""
		  	
				open_modal('button', text: 'Update')
				click_button 'All'
				
				should have_selector 'div.alert-danger'
			end

			describe "shows warnings" do
				it "when location is double booked" do
					pending
				end
					
				it "shows warning when employee is double booked" do
					pending
				end
			end
		end
		
		describe "when 'All Future Events' is selected" do
			it "updates the current event & repeating events in future" do
				visit events_path+'/2014/1/3'
				open_modal(".mash-event")
				click_link 'Edit'
		  	
				fill_in "Title", with: "Repeating UPDATED"
		  	
				open_modal('button', text: 'Update')
				click_button 'All Future Events'
				
				should have_selector 'div.alert-success'
				should have_content 'January 3, 2014'
				should have_content 'Repeating UPDATED'
				
				visit events_path+'/2014/1/4'
				should have_content 'Repeating UPDATED'
				
				visit events_path+'/2014/1/5'
				should have_content 'Repeating UPDATED'
			end
			
			it "does not update the past events" do
				visit events_path+'/2014/1/3'
				open_modal(".mash-event")
				click_link 'Edit'
		  	
				fill_in "Title", with: "Repeating UPDATED"
		  	
				open_modal('button', text: 'Update')
				click_button 'All Future Events'
				
				should have_selector 'div.alert-success'
				
				visit events_path+'/2014/1/1'
				should have_content 'My Repeating'
				
				visit events_path+'/2014/1/2'
				should have_content 'My Repeating'
			end

			it "shows errors" do
				visit events_path+'/2014/1/3'
				open_modal(".mash-event")
				click_link 'Edit'
		  	
				fill_in "Title", with: ""
		  	
				open_modal('button', text: 'Update')
				click_button 'All Future Events'
				
				should have_selector 'div.alert-danger'
			end

			describe "shows warnings" do
				it "when location is double booked" do
					pending
				end
					
				it "shows warning when employee is double booked" do
					pending
				end
			end
		end
	end
	
	context "#destroy", js: true do
		before do
			log_in
			location = FactoryGirl.create(:location, account: current_account)
			Account.current_id = current_account.id
			series = FactoryGirl.create(:event_series, 
								account: current_account,
								title: 'My Repeating',
								location_id: location.id,
								start_date: Date.new(2014,1,1),
								start_time: "11 AM",
								duration: 60,
								period: 'Daily',
								end_date: Date.new(2014,1,5))
		end
		
		describe "has correct Delete options" do
			it "for first event in series" do
				visit events_path+'/2014/1/1'
				open_modal(".mash-event")
				click_link 'Edit'
				open_modal('button', text: 'Delete')
				
				should have_link 'All'
				should have_link 'Only This Event'
			end
			
			it "for 2nd+ event in series" do
				visit events_path+'/2014/1/5'
				open_modal(".mash-event")
				click_link 'Edit'
				open_modal('button', text: 'Delete')
				
				should have_link 'All Future Events'
				should have_link 'Only This Event'
			end
		end
		
		describe "when 'Only This Event' is selected" do
			it "deletes the event" do
				visit events_path+'/2014/1/2'
				open_modal(".mash-event")
				click_link "Edit"
				open_modal('button', text: 'Delete')
				
				click_link 'Only This Event'
				
				should have_selector 'div.alert-success'
				should have_selector 'h2', text: 'January 2, 2014'
				should_not have_content 'My Repeating'
			end
			
			it "does not delete the other repeating events" do
				visit events_path+'/2014/1/2'
				open_modal(".mash-event")
				click_link "Edit"
				open_modal('button', text: 'Delete')
				
				click_link 'Only This Event'
				should have_selector 'div.alert-success'
				
				visit events_path+'/2014/1/1'
				should have_selector 'h2', text: 'January 1, 2014'
				should have_content 'My Repeating'
				
				visit events_path+'/2014/1/3'
				should have_selector 'h2', text: 'January 3, 2014'
				should have_content 'My Repeating'
				
				visit events_path+'/2014/1/4'
				should have_selector 'h2', text: 'January 4, 2014'
				should have_content 'My Repeating'
				
				visit events_path+'/2014/1/5'
				should have_selector 'h2', text: 'January 5, 2014'
				should have_content 'My Repeating'
			end
			
			it "updates the series end_date when the last event in series is deleted" do
				visit events_path+'/2014/1/5'
				open_modal(".mash-event")
				click_link "Edit"
				open_modal('button', text: 'Delete')
				
				click_link 'Only This Event'
				should have_selector 'div.alert-success'
				
				visit events_path+'/2014/1/1'
				should have_selector 'h2', text: 'January 1, 2014'
				open_modal('.mash-event')
				
				should have_content '01/04/2014'
			end
		end
		
		describe "when 'All' is selected" do
			it "deletes the all events in the series" do
				visit events_path+'/2014/1/1'
				open_modal(".mash-event")
				click_link "Edit"
				open_modal('button', text: 'Delete')
				
				click_link 'All'
				should have_selector 'div.alert-success'
				
				visit events_path+'/2014/1/1'
				should have_selector 'h2', text: 'January 1, 2014'
				should_not have_content 'My Repeating'
				
				visit events_path+'/2014/1/2'
				should have_selector 'h2', text: 'January 2, 2014'
				should_not have_content 'My Repeating'
				
				visit events_path+'/2014/1/3'
				should have_selector 'h2', text: 'January 3, 2014'
				should_not have_content 'My Repeating'
				
				visit events_path+'/2014/1/4'
				should have_selector 'h2', text: 'January 4, 2014'
				should_not have_content 'My Repeating'
				
				visit events_path+'/2014/1/5'
				should have_selector 'h2', text: 'January 5, 2014'
				should_not have_content 'My Repeating'
			end
		end
		
		describe "when 'All Future Events' is selected" do
			it "deletes the current event & repeating events in future" do
				visit events_path+'/2014/1/3'
				open_modal(".mash-event")
				click_link "Edit"
				open_modal('button', text: 'Delete')
				
				click_link 'All Future Events'
				should have_selector 'div.alert-success'
				
				visit events_path+'/2014/1/1'
				should have_selector 'h2', text: 'January 1, 2014'
				should have_content 'My Repeating'
				
				visit events_path+'/2014/1/2'
				should have_selector 'h2', text: 'January 2, 2014'
				should have_content 'My Repeating'
				
				visit events_path+'/2014/1/3'
				should have_selector 'h2', text: 'January 3, 2014'
				should_not have_content 'My Repeating'
				
				visit events_path+'/2014/1/4'
				should have_selector 'h2', text: 'January 4, 2014'
				should_not have_content 'My Repeating'
				
				visit events_path+'/2014/1/5'
				should have_selector 'h2', text: 'January 5, 2014'
				should_not have_content 'My Repeating'
			end
			
			it "updates the series end_date" do
				visit events_path+'/2014/1/3'
				open_modal(".mash-event")
				click_link "Edit"
				open_modal('button', text: 'Delete')
				
				click_link 'All Future Events'
				should have_selector 'div.alert-success'
				
				visit events_path+'/2014/1/1'
				should have_selector 'h2', text: 'January 1, 2014'
				should have_content 'My Repeating'
				
				open_modal('.mash-event')
				should have_content '01/02/2014'
			end
		end
	end
end
