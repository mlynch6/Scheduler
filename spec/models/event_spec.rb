# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  account_id       :integer          not null
#  schedulable_id   :integer          not null
#  schedulable_type :string(255)      not null
#  title            :string(30)       not null
#  location_id      :integer
#  start_at         :datetime         not null
#  end_at           :datetime         not null
#  comment          :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe Event do
	let(:account) { FactoryGirl.create(:account) }
	let(:demo) { FactoryGirl.create(:lecture_demo, account: account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:event) { FactoryGirl.create(:event,
											account: account,
											schedulable: demo,
											title: 'Test Event',
											start_date: Date.new(2012,1,1),
											start_time: "9AM",
											duration: 60,
											comment: 'My Comment') }
	
	before do
		Account.current_id = account.id
		@event = FactoryGirl.build(:event)
	end
	
	subject { @event }

	context "accessible attributes" do
		it { should respond_to(:title) }
		it { should respond_to(:start_date) }
		it { should respond_to(:start_time) }
		it { should respond_to(:start_at) }
		it { should respond_to(:end_at) }
		it { should respond_to(:end_time) }
		it { should respond_to(:duration) }
		it { should respond_to(:time_range) }
	  	
		it { should respond_to(:account) }
		it { should respond_to(:schedulable) }
		it { should respond_to(:location) }
		it { should respond_to(:invitations) }
		it { should respond_to(:invitees) }
		it { should respond_to(:invitee_ids) }
		it { should respond_to(:artist_invitations) }
		it { should respond_to(:artists) }
		it { should respond_to(:artist_ids) }
		it { should respond_to(:instructor_invitations) }
		it { should respond_to(:instructors) }
		it { should respond_to(:instructor_ids) }
		it { should respond_to(:musician_invitations) }
		it { should respond_to(:musicians) }
		it { should respond_to(:musician_ids) }
	  	
		it "should not allow access to account_id" do
			expect do
				Event.new(account_id: account.id)
			end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
    
		describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { event.update_attribute(:account_id, new_account.id) }
			
			it { event.reload.account_id.should == account.id }
		end
		
		it "should not allow access to schedulable_id" do
			expect do
				Event.new(schedulable_id: demo.id)
			end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
    
		describe "schedulable_id cannot be changed" do
			let(:new_demo) { FactoryGirl.create(:lecture_demo, account: account) }
			before { event.update_attribute(:schedulable_id, new_demo.id) }
			
			it { event.reload.schedulable.should == demo }
		end
    
    it "should not allow access to start_at" do
      expect do
        Event.new(start_at: Time.zone.now)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    it "should not allow access to end_at" do
      expect do
        Event.new(end_at: Time.zone.now)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
	
  context "(Valid)" do
		it "with minimum attributes" do
			should be_valid
		end
	end

	context "(Invalid)" do
		describe "when title" do
			it "is blank" do
				@event.title = " "
				should_not be_valid
			end
  	
			it "is too long" do
		  		@event.title = "a"*31
		  		should_not be_valid
			end
		end
  	
  	it "when start_date is invalid" do
  		dts = ["abc", "2/31/2012"]
  		dts.each do |invalid_date|
  			@event.start_date = invalid_date
  			should_not be_valid
  		end
		end
	
  	it "when start_time is invalid" do
  		@event.start_time = "abc"
  		should_not be_valid
  	end
  	
  	context "when duration" do
			it "is blank" do
				@event.duration = " "
				should_not be_valid
			end
			
			it "not an integer" do
	  		vals = ["abc", 8.6]
	  		vals.each do |invalid_integer|
	  			@event.duration = invalid_integer
	  			should_not be_valid
	  		end
	  	end
	  	
	  	it "< 1" do
	  		@event.duration = 0
	  		should_not be_valid
	  	end
	  	
	  	it "> 1439 (max min in a day)" do
	  		@event.duration = 1440
	  		should_not be_valid
	  	end
		end
	end
	
  context "(Associations)" do
		describe "has no" do
			it "location" do
				event.reload.location.should be_nil
			end
		end
		
		describe "has one" do
			it "account" do
				event.reload.account.should == account
			end
		
			it "location" do
				event.location = location
				event.save
				event.reload.location.should == location
			end
		end
		
		describe "invitations" do
			let!(:second_invite) { FactoryGirl.create(:invitation, account: account, event: event) }
			let!(:first_invite) { FactoryGirl.create(:invitation, account: account, event: event) }
	
			it "has multiple invitations" do
				event.invitations.count.should == 2
			end
			
			it "deletes associated invitations" do
				invitations = event.invitations
				event.destroy
				invitations.each do |invitation|
					Invitation.find_by_id(invitation.id).should be_nil
				end
			end
		end
		
		describe "invitees" do
			let!(:second_invite) { FactoryGirl.create(:invitation, account: account, event: event) }
			let!(:first_invite) { FactoryGirl.create(:invitation, account: account, event: event) }
	
			it "has multiple invitees" do
				event.invitees.count.should == 2
			end
		end
		
		describe "musician_invitations" do
			let!(:invite1) { FactoryGirl.create(:invitation, :musician, account: account, event: event) }
			let!(:invite2) { FactoryGirl.create(:invitation, :musician, account: account, event: event) }
	
			it "has multiple musician_invitations" do
				event.musician_invitations.count.should == 2
			end
			
			it "deletes associated musician_invitations" do
				musician_invitations = event.musician_invitations
				event.destroy
				musician_invitations.each do |invitation|
					Invitation.find_by_id(invitation.id).should be_nil
				end
			end
		end
		
		describe "musicians" do
			let!(:invite1) { FactoryGirl.create(:invitation, :musician, account: account, event: event) }
			let!(:invite2) { FactoryGirl.create(:invitation, :musician, account: account, event: event) }
	
			it "has multiple musicians" do
				event.musicians.count.should == 2
			end
		end
		
		describe "artist_invitations" do
			let!(:invite1) { FactoryGirl.create(:invitation, :artist, account: account, event: event) }
			let!(:invite2) { FactoryGirl.create(:invitation, :artist, account: account, event: event) }
	
			it "has multiple artist_invitations" do
				event.artist_invitations.count.should == 2
			end
			
			it "deletes associated artist_invitations" do
				artist_invitations = event.artist_invitations
				event.destroy
				artist_invitations.each do |invitation|
					Invitation.find_by_id(invitation.id).should be_nil
				end
			end
		end
		
		describe "artists" do
			let!(:invite1) { FactoryGirl.create(:invitation, :artist, account: account, event: event) }
			let!(:invite2) { FactoryGirl.create(:invitation, :artist, account: account, event: event) }
	
			it "has multiple artists" do
				event.artists.count.should == 2
			end
		end
		
		describe "instructor_invitations" do
			let!(:invite1) { FactoryGirl.create(:invitation, :instructor, account: account, event: event) }
			let!(:invite2) { FactoryGirl.create(:invitation, :instructor, account: account, event: event) }
	
			it "has multiple instructor_invitations" do
				event.instructor_invitations.count.should == 2
			end
			
			it "deletes associated instructor_invitations" do
				instructor_invitations = event.instructor_invitations
				event.destroy
				instructor_invitations.each do |invitation|
					Invitation.find_by_id(invitation.id).should be_nil
				end
			end
		end
		
		describe "instructors" do
			let!(:invite1) { FactoryGirl.create(:invitation, :instructor, account: account, event: event) }
			let!(:invite2) { FactoryGirl.create(:invitation, :instructor, account: account, event: event) }
	
			it "has multiple instructors" do
				event.instructors.count.should == 2
			end
		end
  end
  
	context "correct value is returned for" do
		let(:e2) { Event.find(event.id) }
		
		it "title" do
			e2.title.should == 'Test Event'
	  end
	  
		context "start_date" do
		  it "in default format" do
				e2.start_date.should == '01/01/2012'
		  end
		
		  it "in specified format" do
				e2.start_date(:date_words).should == 'January 1, 2012'
		  end
		end
	  
		context "start_time" do
		  it "in default format" do
				e2.start_time.should == "9:00 AM"
		  end
		
		  it "in specified format" do
				e2.start_time(:hr24).should == "09:00"
		  end
		end
	  
	  it "duration" do
			e2.duration.should == 60
	  end
	  
		context "end_time" do
		  it "in default format" do
				e2.end_time.should == "10:00 AM"
		  end
		
		  it "in specified format" do
				e2.end_time(:hr24).should == "10:00"
		  end
		end
	  
	  it "comment" do
			e2.comment.should == 'My Comment'
	  end
		
		context "time_range" do
		  it "in default format" do
				e2.time_range.should == '9:00 AM to 10:00 AM'
		  end
		
		  it "in specified format" do
				e2.time_range(:hr24).should == '09:00 to 10:00'
		  end
		end
		
		context "event_type" do
		  it "is 'Company Class' when event is a CompanyClass" do
				company_class = FactoryGirl.create(:company_class, account: account)
				e = company_class.events.first
				e.event_type.should == 'Company Class'
		  end
			
		  it "is 'Costume Fitting' when event is a CostumeFitting" do
				costume_fitting = FactoryGirl.create(:costume_fitting, account: account)
				e = FactoryGirl.create(:event, account: account, schedulable: costume_fitting)
				e.event_type.should == 'Costume Fitting'
		  end
			
		  it "is 'Lecture Demo' when event is a LectureDemo" do
				lecture_demo = FactoryGirl.create(:lecture_demo, account: account)
				e = FactoryGirl.create(:event, account: account, schedulable: lecture_demo)
				e.event_type.should == 'Lecture Demo'
		  end
			
		  it "is 'Rehearsal' when event is a Rehearsal" do
				rehearsal = FactoryGirl.create(:rehearsal, account: account)
				e = FactoryGirl.create(:event, account: account, schedulable: rehearsal)
				e.event_type.should == 'Rehearsal'
		  end
		end
  end
	
	context "(Methods)" do
	  describe "search" do
	  	before do
				@date = Date.new(2014,4,10)
				company_class = FactoryGirl.create(:company_class, account: account,
														start_date: (@date-6.days).to_s,
														end_date: @date+5.days,
														monday: true, tuesday: true, wednesday: true, thursday: true,
														friday: true, saturday: true, sunday: true )
			end
			
	  	it "returns all records by default" do
	  		query = {}
				Event.search(query).should == Event.all
		  end
		  
		  describe "on range" do
			  it "=week returns records for the week" do
			  	query = { range: "week", date: @date }
					Event.search(query).should == Event.for_week(@date)
			  end
			  
			  it "=day returns records for the day" do
			  	query = { range: "day", date: @date }
					Event.search(query).should == Event.for_day(@date)
			  end
			  
			  it "that is invalid returns records for the day" do
			  	query = { date: @date }
					Event.search(query).should == Event.for_day(@date)
			  end
			end
	  end
	end

	describe "(Scopes)" do
		before do
			Event.unscoped.delete_all
		end
		
		describe "default_scope" do
			let!(:event3) { FactoryGirl.create(:event, account: account, 
													start_date: Time.zone.today + 1.day,
													start_time: "8AM",
													duration: 30) }
			let!(:event2) { FactoryGirl.create(:event, account: account, 
													start_date: Time.zone.today,
													start_time: "9AM",
													duration: 30) }
			let!(:event1) { FactoryGirl.create(:event, account: account, 
													start_date: Time.zone.today,
													start_time: "8AM",
													duration: 30) }
			let!(:event_wrong_acnt) { FactoryGirl.create(:event, account: FactoryGirl.create(:account)) }
			
			it "returns the records in chronological order by start" do
				Event.all.should == [event1, event2, event3]
			end
		end
		
		describe "for_day" do
			# For December 3, 2012
			let!(:prev_day_bad) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,12,2),
														start_time: "9AM",
														duration: 60) }
			let!(:current_day_good) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,12,3),
														start_time: "12AM",
														duration: 60) }
			let!(:current_day_wrong_acnt) { FactoryGirl.create(:event,
														account: FactoryGirl.create(:account),
														start_date: Date.new(2012,12,3),
														start_time: "9AM",
														duration: 60) }
			let!(:current_day_good2) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,12,3),
														start_time: "11:30PM",
														duration: 30) }
			let!(:current_day_good3) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,12,3),
														start_time: "11AM",
														duration: 60) }
			let!(:wrong_day_bad) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,12,4),
														start_time: "12AM",
														duration: 60) }
			let!(:wrong_day_bad2) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,1,6),
														start_time: "9AM",
														duration: 60) }
			
			it "returns the records for the day" do
				events = Event.for_day(Date.new(2012,12,3))
				events.count.should == 3
				
				events.should include(current_day_good)
				events.should include(current_day_good3)
				events.should include(current_day_good2)
			end
		end
		
		describe "for_week" do
			# For Week containing January 1, 2013
			let!(:prev_week_sun) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,12,30),
														start_time: "11PM",
														duration: 60) }
			let!(:current_week_mon) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,12,31),
														start_time: "12AM",
														duration: 60) }
			let!(:current_week_wrong_acnt) { FactoryGirl.create(:event, 
														start_date: Date.new(2012,1,3),
														start_time: "9AM",
														duration: 60) }
			let!(:current_week_tue) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2013,1,1),
														start_time: "12AM",
														duration: 60) }
			let!(:current_week_wed) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2013,1,2),
														start_time: "12AM",
														duration: 60) }
			let!(:current_week_thu) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2013,1,3),
														start_time: "11PM",
														duration: 30) }
			let!(:current_week_fri) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2013,1,4),
														start_time: "11PM",
														duration: 30) }
			let!(:current_week_sat) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2013,1,5),
														start_time: "11PM",
														duration: 30) }
			let!(:current_week_sun) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2013,1,6),
														start_time: "11:30PM",
														duration: 30) }
			let!(:wrong_week_bad) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2013,1,7),
														start_time: "12AM",
														duration: 60) }
			
			it "returns the records for the week starting on Monday" do
				events = Event.for_week(Date.new(2013,1,1))
				events.count.should == 7
				
				events.should include(current_week_mon)
				events.should include(current_week_tue)
				events.should include(current_week_wed)
				events.should include(current_week_thu)
				events.should include(current_week_fri)
				events.should include(current_week_sat)
				events.should include(current_week_sun)
				
				events.should_not include(prev_week_sun)
				events.should_not include(current_week_wrong_acnt)
				events.should_not include(wrong_week_bad)
			end
		end
	end
end
