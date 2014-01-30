# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
#  title           :string(30)       not null
#  type            :string(20)       default("Event"), not null
#  location_id     :integer          not null
#  start_at        :datetime         not null
#  end_at          :datetime         not null
#  piece_id        :integer
#  event_series_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe Event do
	let(:account) { FactoryGirl.create(:account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:event) { FactoryGirl.create(:event,
											account: account,
											location: location,
											title: 'Test Event',
											start_date: Date.new(2012,1,1),
											start_time: "9AM",
											duration: 60) }
	before do
		Account.current_id = account.id
		@event = FactoryGirl.build(:event)
	end
	
	subject { @event }

	context "accessible attributes" do
		it { should respond_to(:title) }
  	it { should respond_to(:type) }
  	it { should respond_to(:start_date) }
  	it { should respond_to(:start_time) }
  	it { should respond_to(:start_at) }
  	it { should respond_to(:end_at) }
  	it { should respond_to(:end_time) }
  	it { should respond_to(:duration) }
  	it { should respond_to(:piece_id) }
  	it { should respond_to(:period) }
  	it { should respond_to(:end_repeat_on) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:location) }
  	it { should respond_to(:event_series) }
  	it { should respond_to(:invitations) }
  	it { should respond_to(:employees) }
  	
  	it { should respond_to(:employee_ids) }
  	
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
		
		it "should allow access to location_id" do
      expect do
        Event.new(location_id: location.id)
      end.not_to raise_error(ActiveModel::MassAssignmentSecurity::Error)
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
    
    it "should not allow access to event_series_id" do
      expect do
        Event.new(event_series_id: 1)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
	
  context "(Valid)" do
  	it "with minimum attributes" do
  		should be_valid
  	end
  end

	context "(Invalid)" do
		it "when title is blank" do
			@event.title = " "
			should_not be_valid
		end
  	
		it "when title is too long" do
  		@event.title = "a"*31
  		should_not be_valid
  	end
  	
		it "when type is too long" do
  		@event.type = "a"*21
  		should_not be_valid
  	end
  	
		it "when location is blank" do
  		@event.location_id = " "
  		should_not be_valid
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
	
	context "(Verify Location available)" do
		let!(:existing_event) { FactoryGirl.create(:event, account: account, location: location, 
																start_date: Time.zone.today,
  															start_time: "2PM",
  															duration: 120) }
  	let!(:e_loc) { FactoryGirl.create(:event, account: account,
  															start_date: Time.zone.today,
  															start_time: "2PM",
  															duration: 120) }
		let!(:e) { FactoryGirl.create(:event, account: account, location: location,
																start_date: Time.zone.today,
  															start_time: "11AM",
  															duration: 60) }
  	
  	describe "when creating a new event" do
			it "directly before existing event" do
	  		@event.location = location
	  		@event.start_date = Time.zone.today
				@event.start_time = "1PM"
				@event.duration = 60
	  		should be_valid
	  	end
	  	
	  	it "directly after existing event" do
	  		@event.location = location
	  		@event.start_date = Time.zone.today
				@event.start_time = "4PM"
				@event.duration = 60
	  		should be_valid
	  	end
	  	
	  	it "with overlap at beginning" do
	  		@event.location = location
	  		@event.start_date = existing_event.start_date
				@event.start_time = "1PM"
				@event.duration = 120
		  	should_not be_valid
		  end
		  
		  it "with overlap at end" do
		  	@event.location = location
		  	@event.start_date = existing_event.start_date
				@event.start_time = "3PM"
				@event.duration = 120
		  	should_not be_valid
		  end
		  
		  it "with overlap entire event" do
		  	@event.location = location
		  	@event.start_date = existing_event.start_date
				@event.start_time = "1PM"
				@event.duration = 240
		  	should_not be_valid
		  end
		  
		  it "with overlap within existing event" do
		  	@event.location = location
		  	@event.start_date = existing_event.start_date
				@event.start_time = "3PM"
				@event.duration = 30
		  	should_not be_valid
		  end
		  
		  it "with overlap of exact times" do
		  	@event.location = location
		  	@event.start_date = existing_event.start_date
				@event.start_time = "2PM"
				@event.duration = 120
		  	should_not be_valid
		  end
	  end
	
		describe "when updating an existing event" do
	  	it "location to booked room is invalid" do
	  		e_loc.location = location
		  	e_loc.should_not be_valid
		  end
		  
		  it "times to overlap existing event at beginning is invalid" do
	  		e.start_time = "1PM"
				e.duration = 120
		  	e.should_not be_valid
		  end
		  
		  it "times to overlap existing event at end is invalid" do
		  	e.start_time = "3PM"
				e.duration = 120
		  	e.should_not be_valid
		  end
		  
		  it "times to overlap entire existing event is invalid" do
		  	e.start_time = "1PM"
				e.duration = 240
		  	e.should_not be_valid
		  end
		  
		  it "times to overlap existing event as a subset is invalid" do
		  	e.start_time = "3PM"
				e.duration = 30
		  	e.should_not be_valid
		  end
		  
		  it "times to overlap of exactly is invalid" do
				e.start_time = existing_event.start_time
				e.duration = existing_event.duration
		  	e.should_not be_valid
		  end
		  
			it "times directly before existing event is valid" do
		  	e.start_time = "1PM"
				e.duration = 60
		  	e.should be_valid
		  end
		  
		  it "times directly after existing event is valid" do
		  	e.start_time = "4PM"
				e.duration = 60
		  	e.should be_valid
		  end
		end
	end
	
  context "(Associations)" do
		it "has one account" do
			event.reload.account.should == account
		end
		
		it "has one location" do
			event.reload.location.should == location
		end
		
		it "has one series" do
			series = FactoryGirl.create(:event_series)
			event1 = series.events.first
			event1.event_series.should == series
		end
		
		describe "invitations" do
			let(:employee1) { FactoryGirl.create(:employee, account: account) }
			let(:employee2) { FactoryGirl.create(:employee, account: account) }
			let!(:second_invite) { FactoryGirl.create(:invitation, event: event, employee: employee1) }
			let!(:first_invite) { FactoryGirl.create(:invitation, event: event, employee: employee2) }
	
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
		
		describe "employees" do
			let(:employee1) { FactoryGirl.create(:employee, account: account) }
			let(:employee2) { FactoryGirl.create(:employee, account: account) }
			let!(:second_invite) { FactoryGirl.create(:invitation, event: event, employee: employee1) }
			let!(:first_invite) { FactoryGirl.create(:invitation, event: event, employee: employee2) }
	
			it "has multiple employees" do
				event.employees.count.should == 2
			end
		end
  end
  
	context "correct value is returned for" do
		it "title" do
	  	event.reload.title.should == 'Test Event'
	  end
	  
	  it "type" do
	  	event.reload.type.should == 'Event'
	  end
	  
	  it "start_date" do
			event.reload.start_date.should == Date.new(2012,1,1)
	  end
	  
	  it "start_time" do
			event.reload.start_time.should == "9AM"
	  end
	  
	  it "duration" do
			event.reload.duration.should == 60
	  end
	  
	  it "end_time" do
			event.reload.end_time.should == "10:00 AM"
	  end
	  
	  it "start_at" do
			event.reload.start_at.to_date.to_s(:db).should == "2012-01-01"
			event.reload.start_at.to_s(:hr12).should == "9:00 AM"
	  end
	  
	  it "end_at" do
			event.reload.end_at.to_date.to_s(:db).should == "2012-01-01"
			event.reload.end_at.to_s(:hr12).should == "10:00 AM"
	  end
  end
  
  context "(Methods)" do	  
	  context "overlapping" do
	  	let!(:e) { FactoryGirl.create(:event,
											account: account,
											location: location,
											start_date: Date.new(2012,1,2),
											start_time: "1PM",
											duration: 60) }
											
	  	let!(:location2) { FactoryGirl.create(:location, account: account) }
	  	let!(:location3) { FactoryGirl.create(:location, account: account) }
	  	let!(:overlap_start) { FactoryGirl.create(:event,
											account: account,
											location: location2,
											start_date: Date.new(2012,1,2),
											start_time: "12:15 PM",
											duration: 60) }
			let!(:overlap_subset) { FactoryGirl.create(:event,
											account: account,
											location: location2,
											start_date: Date.new(2012,1,2),
											start_time: "1:15 PM",
											duration: 30) }
			let!(:overlap_end) { FactoryGirl.create(:event,
											account: account,
											location: location2,
											start_date: Date.new(2012,1,2),
											start_time: "1:45 PM",
											duration: 60) }
			let!(:overlap_entire) { FactoryGirl.create(:event,
											account: account,
											location: location3,
											start_date: Date.new(2012,1,2),
											start_time: "12:00 PM",
											duration: 155) }
			let!(:before_event) { FactoryGirl.create(:event,
											account: account,
											location: location,
											start_date: Date.new(2012,1,2),
											start_time: "12:30 PM",
											duration: 30) }
			let!(:after_event) { FactoryGirl.create(:event,
											account: account,
											location: location,
											start_date: Date.new(2012,1,2),
											start_time: "2:00 PM",
											duration: 90) }
			let!(:day_before) { FactoryGirl.create(:event,
											account: account,
											location: location,
											start_date: Date.new(2012,1,1)) }
			let!(:day_after) { FactoryGirl.create(:event,
											account: account,
											location: location,
											start_date: Date.new(2012,1,3)) }
			
			it "shows events that have an overlap" do
				e.overlapping.should include(overlap_start)
				e.overlapping.should include(overlap_subset)
				e.overlapping.should include(overlap_end)
				e.overlapping.should include(overlap_entire)
				
				e.overlapping.should_not include(e)
				e.overlapping.should_not include(before_event)
				e.overlapping.should_not include(after_event)
				e.overlapping.should_not include(day_before)
				e.overlapping.should_not include(day_after)
			end
	  end
	  
	  context "double_booked_employees_warning" do
			let(:location2) { FactoryGirl.create(:location, account: account) }
			let(:e1) { FactoryGirl.create(:employee, account: account) }
			let(:e2) { FactoryGirl.create(:employee, account: account) }
			let(:e3) { FactoryGirl.create(:employee, account: account) }
			let!(:event1) { FactoryGirl.create(:event, account: account, 
													location: location,
													start_date: Time.zone.today,
													start_time: "8AM",
													duration: 30) }
			let!(:i1) { FactoryGirl.create(:invitation, event: event1, employee: e1) }
			let!(:i2) { FactoryGirl.create(:invitation, event: event1, employee: e2) }
			let!(:i3) { FactoryGirl.create(:invitation, event: event1, employee: e3) }
			
			let!(:event2) { FactoryGirl.create(:event, account: account, 
													location: location,
													start_date: Time.zone.today,
													start_time: "9AM",
													duration: 30) }
			let!(:i4) { FactoryGirl.create(:invitation, event: event2, employee: e1) }
			
			it "gives warning message for double booked employees" do
				event.start_date = Time.zone.today
				event.start_time = "8AM"
				event.duration = 90
				event.employee_ids = [e1.id]
				event.save
				event.double_booked_employees_warning.should == "The following people are double booked during this time: #{e1.full_name}"
			end
		end
		
		context "new_with_subclass" do
			it "creates a new Company Class" do
				e = Event.new_with_subclass('CompanyClass')
				e.class.should == CompanyClass
			end
			
			it "creates a new Costume Fitting" do
				e = Event.new_with_subclass('CostumeFitting')
				e.class.should == CostumeFitting
				e.type.should == 'CostumeFitting'
			end
			
			it "creates a new Rehearsal" do
				e = Event.new_with_subclass('Rehearsal')
				e.class.should == Rehearsal
				e.type.should == 'Rehearsal'
			end
			
			it "creates a new Event" do
				e = Event.new_with_subclass('Event')
				e.class.should == Event
				e.type.should == 'Event'
			end
			
			it "creates a new Event when no type specified" do
				e = Event.new_with_subclass(nil)
				e.class.should == Event
				e.type.should == 'Event'
			end
			
			it "creates a new Event when invalid type is specified" do
				e = Event.new_with_subclass('Invalid')
				e.class.should == Event
				e.type.should == 'Event'
			end
			
			it "with params creates Event" do
				params = { location_id: location.id,
									title: 'Test Event',
									start_date: Date.new(2012,1,1),
									start_time: "9AM",
									duration: 60 }
				e = Event.new_with_subclass('Event', params)
				e.class.should == Event
				
				e.location.should == location
				e.title.should == params[:title]
				e.start_date.should == params[:start_date]
				e.start_time.should == params[:start_time]
				e.duration.should == params[:duration]
				
				e.valid?.should be_true
			end
		end
  end

	describe "(Scopes)" do
		before do
			account.events.delete_all
		end
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
		let!(:location_wrong_acnt) { FactoryGirl.create(:event) }
		
		describe "default_scope" do	
			it "returns the records in chronological order by start" do
				Event.all.should == [event1, event2, event3]
			end
		end
		
		describe "for_daily_calendar" do
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
														start_date: Date.new(2012,12,3),
														start_time: "9AM",
														duration: 60) }
			let!(:current_day_good2) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,12,3),
														start_time: "3PM",
														duration: 60) }
			let!(:current_day_good3) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,12,3),
														start_time: "11AM",
														duration: 60) }
			let!(:wrong_day_bad) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2013,1,6),
														start_time: "9AM",
														duration: 60) }
			
			it "returns the records for the day" do
				Event.for_daily_calendar(Date.parse("2012-12-3")).should == [current_day_good, current_day_good3, current_day_good2]
			end
		end
		
		describe "for_week" do
			# For Week containing January 1, 2013
			let!(:prev_week_sun) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,12,30),
														start_time: "9AM",
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
														start_date: Date.new(2013,1,4),
														start_time: "11PM",
														duration: 30) }
			let!(:wrong_week_bad) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2013,1,7),
														start_time: "11AM",
														duration: 60) }
			
			it "returns the records for the week starting on Monday" do
				events = Event.for_week(Date.new(2013,1,1))
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
		
		describe "for_monthly_calendar" do
			# Dates for December 2012
			let!(:prev_month_bad) { FactoryGirl.create(:event, account: account,
														start_date: Date.new(2012,11,4)) }
			let!(:prev_month_good) { FactoryGirl.create(:event, account: account,
														start_date: Date.new(2012,11,25)) }
			let!(:prev_month_good2) { FactoryGirl.create(:event, account: account,
														start_date: Date.new(2012,11,26)) }
			let!(:current_month_good) { FactoryGirl.create(:event, account: account,
														start_date: Date.new(2012,12,1)) }
			let!(:current_month_wrong_acnt) { FactoryGirl.create(:event,
														start_date: Date.new(2012,12,1)) }
			let!(:current_month_good2) { FactoryGirl.create(:event, account: account,
														start_date: Date.new(2012,12,15)) }
			let!(:current_month_good3) { FactoryGirl.create(:event, account: account,
														start_date: Date.new(2012,12,31)) }
			let!(:next_month_good) { FactoryGirl.create(:event, account: account,
														start_date: Date.new(2013,1,1)) }
			let!(:next_month_good2) { FactoryGirl.create(:event, account: account,
														start_date: Date.new(2013,1,5)) }
			let!(:next_month_bad) { FactoryGirl.create(:event, account: account,
														start_date: Date.new(2013,1,6)) }
			
			it "returns the records for the month plus days from previous/future month that would appear on a calendar" do
				Event.for_monthly_calendar(DateTime.parse("2012-12-7 09:00:00")).should == [prev_month_good, prev_month_good2, current_month_good, current_month_good2, current_month_good3, next_month_good, next_month_good2]
			end
		end
	end
end
