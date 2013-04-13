# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  account_id  :integer          not null
#  title       :string(30)       not null
#  type        :string(20)       not null
#  location_id :integer          not null
#  start_at    :datetime         not null
#  end_at      :datetime         not null
#  piece_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
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
											end_time: "10AM") }
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
  	it { should respond_to(:end_time) }
  	it { should respond_to(:start_at) }
  	it { should respond_to(:end_at) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:location) }
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
  	
		it "when type is blank" do
  		@event.type = " "
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
  	
  	it "when start_date in is invalid" do
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
  	
  	it "when end_time is invalid" do
  		@event.end_time = "abc"
  		should_not be_valid
  	end
  	
		it "when end_time same as start_time" do
			@event.start_time = 2.hours.ago.to_s(:hr12)
			@event.end_time = @event.start_at
	  	should_not be_valid
	  end
	  
		it "when end_at is before start_at" do
			@event.start_time = 1.hour.ago.to_s(:hr12)
			@event.end_time = 2.hours.ago.to_s(:hr12)
	  	should_not be_valid
	  end
	end
	
	context "(Verify Location available)" do
		let!(:existing_event) { FactoryGirl.create(:event, account: account, location: location, 
																start_date: Time.zone.today,
  															start_time: "2PM",
  															end_time: "4PM") }
  	let!(:e_loc) { FactoryGirl.create(:event, account: account,
  															start_date: Time.zone.today,
  															start_time: "2PM",
  															end_time: "4PM") }
		let!(:e) { FactoryGirl.create(:event, account: account, location: location,
																start_date: Time.zone.today,
  															start_time: "11AM",
  															end_time: "12PM") }
  	
  	describe "when creating a new event" do
			it "directly before existing event" do
	  		@event.location = location
	  		@event.start_date = Time.zone.today
				@event.start_time = "1PM"
				@event.end_time = "2PM"
	  		should be_valid
	  	end
	  	
	  	it "directly after existing event" do
	  		@event.location = location
	  		@event.start_date = Time.zone.today
				@event.start_time = "4PM"
				@event.end_time = "5PM"
	  		should be_valid
	  	end
	  	
	  	it "with overlap at beginning" do
	  		@event.location = location
	  		@event.start_date = existing_event.start_date
				@event.start_time = "1PM"
				@event.end_time = "3PM"
		  	should_not be_valid
		  end
		  
		  it "with overlap at end" do
		  	@event.location = location
		  	@event.start_date = existing_event.start_date
				@event.start_time = "3PM"
				@event.end_time = "5PM"
		  	should_not be_valid
		  end
		  
		  it "with overlap entire event" do
		  	@event.location = location
		  	@event.start_date = existing_event.start_date
				@event.start_time = "1PM"
				@event.end_time = "5PM"
		  	should_not be_valid
		  end
		  
		  it "with overlap within existing event" do
		  	@event.location = location
		  	@event.start_date = existing_event.start_date
				@event.start_time = "3PM"
				@event.end_time = "3:30PM"
		  	should_not be_valid
		  end
		  
		  it "with overlap of exact times" do
		  	@event.location = location
		  	@event.start_date = existing_event.start_date
				@event.start_time = "2PM"
				@event.end_time = "4PM"
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
				e.end_time = "3PM"
		  	e.should_not be_valid
		  end
		  
		  it "times to overlap existing event at end is invalid" do
		  	e.start_time = "3PM"
				e.end_time = "5PM"
		  	e.should_not be_valid
		  end
		  
		  it "times to overlap entire existing event is invalid" do
		  	e.start_time = "1PM"
				e.end_time = "5PM"
		  	e.should_not be_valid
		  end
		  
		  it "times to overlap existing event as a subset is invalid" do
		  	e.start_time = "3PM"
				e.end_time = "3:30PM"
		  	e.should_not be_valid
		  end
		  
		  it "times to overlap of exactly is invalid" do
				e.start_time = existing_event.start_time
				e.end_time = existing_event.end_time
		  	e.should_not be_valid
		  end
		  
			it "times directly before existing event is valid" do
		  	e.start_time = "1PM"
				e.end_time = "2PM"
		  	e.should be_valid
		  end
		  
		  it "times directly after existing event is valid" do
		  	e.start_time = "4PM"
				e.end_time = "5PM"
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
	  
	  it "end_time" do
			event.reload.end_time.should == "10AM"
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
		it "duration_min" do
			event.start_date = Time.zone.today
			event.start_time = "9:30 AM"
			event.end_time = "10:15 AM"
			event.save
	  	event.reload.duration_min.should == 45
	  end
  end

	describe "(Scopes)" do
		before do
			account.events.delete_all
		end
		let!(:event3) { FactoryGirl.create(:event, account: account, 
												start_date: Time.zone.today + 1.day,
												start_time: "8AM", end_time: "8:30AM") }
		let!(:event2) { FactoryGirl.create(:event, account: account, 
												start_date: Time.zone.today,
												start_time: "9AM", end_time: "9:30AM") }
		let!(:event1) { FactoryGirl.create(:event, account: account, 
												start_date: Time.zone.today,
												start_time: "8AM", end_time: "8:30AM") }
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
														start_time: "9AM", end_time: "10am") }
			let!(:current_day_good) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,12,3),
														start_time: "12AM", end_time: "1pm") }
			let!(:current_day_wrong_acnt) { FactoryGirl.create(:event, 
														start_date: Date.new(2012,12,3),
														start_time: "9AM", end_time: "10am") }
			let!(:current_day_good2) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,12,3),
														start_time: "3PM", end_time: "4pm") }
			let!(:current_day_good3) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2012,12,3),
														start_time: "11AM", end_time: "12pm") }
			let!(:wrong_day_bad) { FactoryGirl.create(:event, account: account, 
														start_date: Date.new(2013,1,6),
														start_time: "9AM", end_time: "10am") }
			
			it "returns the records for the day" do
				Event.for_daily_calendar(DateTime.parse("2012-12-3 01:00:00")).should == [current_day_good, current_day_good3, current_day_good2]
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
	
	describe "(Custom Error Messages)" do
		pending
	end
end
