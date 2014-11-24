require 'spec_helper'

describe "Invitee Pages:" do
	subject { page }
	
	context "for Company Classes" do
		context "#index" do
			before do
	  		log_in
	  		@company_class = FactoryGirl.create(:company_class, account: current_account,
									start_date: '10/1/2014',
									start_time: '9:15 AM',
									duration: 60,
									end_date: '10/7/2014',
									thursday: true)
				Account.current_id = current_account.id
				@event = @company_class.events.first
	  		click_link "Calendar"
		  	click_link "Company Classes"
				click_link @company_class.title
				click_link "Dates"
				click_link "October 2, 2014"
				click_link "Invitees"
			end
	
	  	it "has correct title" do
		  	should have_title "#{@company_class.title} | Invitees"
			  should have_selector 'h1', text: @company_class.title
				should have_selector 'h1 small', text: 'Invitees'
			end
	
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Calendar'
				should have_selector 'li.active', text: 'Company Classes'
				should have_selector 'li.active', text: 'Invitees'
			end
	
			it "has correct fields" do
				should have_selector 'div.dtl-label', text: "Instructors"
				should have_selector 'div.dtl-label', text: "Musicians"
				should have_selector 'div.dtl-label', text: "Artists"
			end
  
			it "lists Instructor records" do
				4.times { FactoryGirl.create(:invitation, :instructor, account: current_account, event: @event) }
				click_link "Invitees"
		
				Account.current_id = current_account.id
				records = @event.invitees
				records.count.should > 0
		
				records.each do |person|
					should have_content person.full_name
		    end
			end
	
			it "has links for Super Admin" do
				should have_link 'Edit Invitees'
			end
		end
	
		context "#new" do
			before do
				log_in
				@person = FactoryGirl.create(:person, :instructor, account: current_account)
	  		@company_class = FactoryGirl.create(:company_class, account: current_account,
									start_date: '10/1/2014',
									start_time: '9:15 AM',
									duration: 60,
									end_date: '10/7/2014')
				click_link 'Calendar'
				click_link "Company Classes"
		  	click_link @company_class.title
				click_link "Dates"
				click_link "October 2, 2014"
				click_link "Invitees"
				click_link 'Edit Invitees'
			end
		
			it "has correct title" do	
		  	should have_title "#{@company_class.title} | Edit Invitees"
			  should have_selector 'h1', text: @company_class.title
				should have_selector 'h1 small', text: 'Edit Invitees'
			end
		
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Calendar'
				should have_selector 'li.active', text: 'Company Classes'
				should have_selector 'li.active', text: 'Invitees'
			end
		
			it "has correct fields on form" do
				Account.current_id = current_account.id
				@event = @company_class.events.first
				
				should have_field 'Instructors'
				should have_field 'Musicians'
				should have_field 'Artists'
				should have_link 'Cancel', href: schedule_event_invitees_path(@event)
			end
	 
			it "record with valid info saves record", js: true do
				select_from_chosen @person.name, from: "Instructors"
				click_button 'Update'
	
				should have_selector 'div.alert-success'
				should have_title "#{@company_class.title} | Invitees"
				should have_content @person.full_name
			end
		end
	end
	
	context "for Costume Fittings" do
		context "#index" do
			before do
	  		log_in
				@fitting = FactoryGirl.create(:costume_fitting, account: current_account)
				@event = FactoryGirl.create(:event, account: current_account, schedulable: @fitting)
	  		click_link "Calendar"
		  	click_link "Costume Fittings"
				click_link @fitting.title
				click_link "Invitees"
			end
	
	  	it "has correct title" do	
		  	should have_title "#{@fitting.title} | Invitees"
			  should have_selector 'h1', text: @fitting.title
				should have_selector 'h1 small', text: 'Invitees'
			end
	
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Calendar'
				should have_selector 'li.active', text: 'Costume Fittings'
				should have_selector 'li.active', text: 'Invitees'
			end
	
			it "has correct fields" do
				should have_selector 'div.dtl-label', text: "Invitees"
			end
  
			it "lists records" do
				4.times { FactoryGirl.create(:invitation, account: current_account, event: @event) }
				click_link "Invitees"
		
				Account.current_id = current_account.id
				records = @fitting.invitees
				records.count.should > 0
		
				records.each do |person|
					should have_content person.full_name
		    end
			end
	
			it "has links for Super Admin" do
				should have_link 'Edit Invitees'
			end
		end
	
		context "#new" do
			before do
				log_in
				@person = FactoryGirl.create(:person, account: current_account)
				@fitting = FactoryGirl.create(:costume_fitting, account: current_account)
				@event = FactoryGirl.create(:event, :with_location, account: current_account, schedulable: @fitting)
				click_link 'Calendar'
				click_link 'Costume Fittings'
		  	click_link @fitting.title
				click_link 'Invitees'
				click_link 'Edit Invitees'
			end
		
			it "has correct title" do	
		  	should have_title "#{@fitting.title} | Edit Invitees"
			  should have_selector 'h1', text: @fitting.title
				should have_selector 'h1 small', text: 'Edit Invitees'
			end
		
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Calendar'
				should have_selector 'li.active', text: 'Costume Fittings'
				should have_selector 'li.active', text: 'Invitees'
			end
		
			it "has correct fields on form" do
				should have_field 'Invitees'
				should have_link 'Cancel', href: schedule_event_invitees_path(@event)
			end
	 
			it "record with valid info saves record", js: true do
				select_from_chosen @person.name, from: "Invitees"
				click_button 'Update'
	
				should have_selector 'div.alert-success'
				should have_title "#{@fitting.title} | Invitees"
				should have_content @person.full_name
			end
		end
	end
  
	context "for Lecture Demos" do
		context "#index" do
			before do
	  		log_in
				@demo = FactoryGirl.create(:lecture_demo, account: current_account)
				@event = FactoryGirl.create(:event, :with_location, account: current_account, schedulable: @demo)
				click_link 'Calendar'
				click_link 'Lecture Demos'
		  	click_link @demo.title
				click_link "Invitees"
			end
	
	  	it "has correct title" do	
		  	should have_title "#{@demo.title} | Invitees"
			  should have_selector 'h1', text: @demo.title
				should have_selector 'h1 small', text: 'Invitees'
			end
	
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Calendar'
				should have_selector 'li.active', text: 'Lecture Demos'
				should have_selector 'li.active', text: 'Invitees'
			end
	
			it "has correct fields" do
				should have_selector 'div.dtl-label', text: "Invitees"
			end
  
			it "lists records" do
				4.times { FactoryGirl.create(:invitation, account: current_account, event: @event) }
				click_link "Invitees"
		
				Account.current_id = current_account.id
				records = @demo.invitees
				records.count.should > 0
		
				records.each do |person|
					should have_content person.full_name
		    end
			end
	
			it "has links for Super Admin" do
				should have_link 'Edit Invitees'
			end
		end
	
		context "#new" do
			before do
				log_in
				@person = FactoryGirl.create(:person, account: current_account)
				@demo = FactoryGirl.create(:lecture_demo, account: current_account)
				@event = FactoryGirl.create(:event, :with_location, account: current_account, schedulable: @demo)
				click_link 'Calendar'
				click_link 'Lecture Demos'
		  	click_link @demo.title
				click_link 'Invitees'
				click_link 'Edit Invitees'
			end
		
			it "has correct title" do	
		  	should have_title "#{@demo.title} | Edit Invitees"
			  should have_selector 'h1', text: @demo.title
				should have_selector 'h1 small', text: 'Edit Invitees'
			end
		
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Calendar'
				should have_selector 'li.active', text: 'Lecture Demos'
				should have_selector 'li.active', text: 'Invitees'
			end
		
			it "has correct fields on form" do
				should have_field 'Invitees'
				should have_link 'Cancel', href: schedule_event_invitees_path(@event)
			end
	 
			it "record with valid info saves record", js: true do
				select_from_chosen @person.name, from: "Invitees"
				click_button 'Update'
	
				should have_selector 'div.alert-success'
				should have_title "#{@demo.title} | Invitees"
				should have_content @person.full_name
			end
		end
	end
	
	context "for Rehearsals" do
		context "#index" do
			before do
	  		log_in
				@rehearsal = FactoryGirl.create(:rehearsal, account: current_account)
				@event = FactoryGirl.create(:event, :with_location, account: current_account, schedulable: @rehearsal)
	  		click_link "Calendar"
		  	click_link "Rehearsals"
				click_link @rehearsal.title
				click_link "Invitees"
			end
	
	  	it "has correct title" do	
		  	should have_title "#{@rehearsal.title} | Invitees"
			  should have_selector 'h1', text: @rehearsal.title
				should have_selector 'h1 small', text: 'Invitees'
			end
	
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Calendar'
				should have_selector 'li.active', text: 'Rehearsals'
				should have_selector 'li.active', text: 'Invitees'
			end
	
			it "has correct fields" do
				should have_selector 'div.dtl-label', text: "Instructors"
				should have_selector 'div.dtl-label', text: "Musicians"
				should have_selector 'div.dtl-label', text: "Artists"
			end
  
			it "lists instructors" do
				3.times { invitation = FactoryGirl.create(:invitation, :instructor, account: current_account, event: @event) }
			
				click_link "Invitees"
		
				Account.current_id = current_account.id
				instructors = @rehearsal.instructors
				instructors.count.should > 0
		
				instructors.each do |person|
					should have_content person.full_name
		    end
			end
		
			it "lists musicians" do
				3.times { invitation = FactoryGirl.create(:invitation, :musician, account: current_account, event: @event) }
			
				click_link "Invitees"
		
				Account.current_id = current_account.id
				musicians = @rehearsal.musicians
				musicians.count.should > 0
		
				musicians.each do |person|
					should have_content person.full_name
		    end
			end
		
			it "lists artists" do
				3.times { invitation = FactoryGirl.create(:invitation, :artist, account: current_account, event: @event) }
		
				click_link "Invitees"
		
				Account.current_id = current_account.id
				artists = @rehearsal.artists
				artists.count.should > 0
		
				artists.each do |person|
					should have_content person.full_name
		    end
			end
	
			it "has links for Super Admin" do
				should have_link 'Edit Invitees'
			end
		end
	
		context "#new" do
			before do
				log_in
				@instructor = FactoryGirl.create(:person, :instructor, account: current_account)
				@musician = FactoryGirl.create(:person, :musician, account: current_account)
				@person = FactoryGirl.create(:person, account: current_account)
				@rehearsal = FactoryGirl.create(:rehearsal, account: current_account)
				@event = FactoryGirl.create(:event, :with_location, account: current_account, schedulable: @rehearsal)
	  		click_link "Calendar"
		  	click_link "Rehearsals"
				click_link @rehearsal.title
				click_link "Invitees"
				click_link 'Edit Invitees'
			end
		
			it "has correct title" do	
		  	should have_title "#{@rehearsal.title} | Edit Invitees"
			  should have_selector 'h1', text: @rehearsal.title
				should have_selector 'h1 small', text: 'Edit Invitees'
			end
		
			it "has correct Navigation" do
				should have_selector 'li.active', text: 'Calendar'
				should have_selector 'li.active', text: 'Rehearsals'
				should have_selector 'li.active', text: 'Invitees'
			end
		
			it "has correct fields on form" do
				should have_field 'Instructors'
				should have_field 'Musicians'
				should have_field 'Artists'
				should have_link 'Cancel', href: schedule_event_invitees_path(@event)
			end
	 
			it "record with valid info saves record", js: true do
				select_from_chosen @instructor.name, from: "Instructors"
				select_from_chosen @musician.name, from: "Musicians"
				select_from_chosen @person.name, from: "Artists"
				click_button 'Update'
	
				should have_selector 'div.alert-success'
				should have_title "#{@rehearsal.title} | Invitees"
				should have_content @instructor.full_name
				should have_content @musician.full_name
				should have_content @person.full_name
			end
		end
	end
end