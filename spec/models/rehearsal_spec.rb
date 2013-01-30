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

describe Rehearsal do
	let(:account) { FactoryGirl.create(:account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:piece) { FactoryGirl.create(:piece, account: account) }
	let(:event_start) { 2.hours.ago }
	let(:rehearsal) { FactoryGirl.create(:rehearsal,
											account: account,
											location: location,
											title: 'Test Event',
											start_at: event_start,
											end_at: event_start+1.hour,
											piece: piece) }
	before do
		Account.current_id = account.id
		@rehearsal = FactoryGirl.build(:rehearsal)
	end
	
	subject { @rehearsal }

	context "accessible attributes" do
		it { should respond_to(:title) }
  	it { should respond_to(:type) }
  	it { should respond_to(:start_at) }
  	it { should respond_to(:end_at) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:location) }
  	it { should respond_to(:piece) }
  	
  	it "should not allow access to account_id" do
      expect do
        Rehearsal.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { rehearsal.update_attribute(:account_id, new_account.id) }
			
			it { rehearsal.reload.account_id.should == account.id }
		end
		
		it "should allow access to location_id" do
      expect do
        Rehearsal.new(location_id: location.id)
      end.not_to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    it "should allow access to piece_id" do
      expect do
        Rehearsal.new(piece_id: piece.id)
      end.not_to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end

	context "(Invalid)" do
		it "when title is blank" do
			@rehearsal.title = " "
			should_not be_valid
		end
  	
		it "when title is too long" do
  		@rehearsal.title = "a"*31
  		should_not be_valid
  	end
  	
		it "when type is blank" do
  		@rehearsal.type = " "
  		should_not be_valid
  	end
  	
		it "when type is too long" do
  		@rehearsal.type = "a"*21
  		should_not be_valid
  	end
  	
		it "when location is blank" do
  		@rehearsal.location_id = " "
  		should_not be_valid
  	end
  	
		it "when start_at is blank" do
  		@rehearsal.start_at = " "
  		should_not be_valid
  	end
  	
		it "when start_at is a bad date" do
  		@rehearsal.start_at = "2012-02-31 07:00:00"
  		should_not be_valid
  	end
  	
		it "when end_at is blank" do
  		@rehearsal.end_at = " "
  		should_not be_valid
  	end
  	
		it "when end_at is a bad date" do
  		@rehearsal.end_at = "2012-02-31 07:00:00"
  		should_not be_valid
  	end
  	
		it "when end_at same as start_at" do
			@rehearsal.start_at = 2.hours.ago
			@rehearsal.end_at = @rehearsal.start_at
	  	should_not be_valid
	  end
	  
		it "when end_at is before start_at" do
			@rehearsal.start_at = 1.hour.ago
			@rehearsal.end_at = 2.hours.ago
	  	should_not be_valid
	  end
	  
	  describe "when location is already booked" do
	  	let!(:existing_rehearsal) { FactoryGirl.create(:rehearsal, account: account, location: location, 
	  															start_at: 4.hours.ago, end_at: 2.hours.ago) }
	  	
	  	it "with overlap at beginning" do
	  		@rehearsal.location = location
				@rehearsal.start_at = 5.hours.ago
				@rehearsal.end_at = 3.hours.ago
		  	should_not be_valid
		  end
		  
		  it "with overlap at end" do
		  	@rehearsal.location = location
				@rehearsal.start_at = 3.hours.ago
				@rehearsal.end_at = 1.hour.ago
		  	should_not be_valid
		  end
		  
		  it "with overlap entire event" do
		  	@rehearsal.location = location
				@rehearsal.start_at = 5.hours.ago
				@rehearsal.end_at = 1.hour.ago
		  	should_not be_valid
		  end
		  
		  it "with overlap within existing event" do
		  	@rehearsal.location = location
				@rehearsal.start_at = 3.hours.ago
				@rehearsal.end_at = 3.hours.ago + 30.minutes
		  	should_not be_valid
		  end
		  
		  it "with overlap of exact times" do
		  	@rehearsal.location = location
				@rehearsal.start_at = existing_rehearsal.start_at
				@rehearsal.end_at = existing_rehearsal.end_at
		  	should_not be_valid
		  end
	  end
	end
	
	context "(Updating)" do
		let!(:existing_rehearsal) { FactoryGirl.create(:rehearsal, account: account, location: location, 
  															start_at: 4.hours.ago, end_at: 2.hours.ago) }
  	let!(:r_loc) { FactoryGirl.create(:rehearsal, account: account,
  															start_at: 4.hours.ago, end_at: 2.hours.ago) }
		let!(:r) { FactoryGirl.create(:rehearsal, account: account, location: location,
  															start_at: 6.hours.ago, end_at: 5.hours.ago) }

  	it "location to booked room" do
  		r_loc.location = location
	  	r_loc.should_not be_valid
	  end
	  
	  it "times to overlap existing event at beginning" do
  		r.start_at = 5.hour.ago
			r.end_at = 3.hours.ago
	  	r.should_not be_valid
	  end
	  
	  it "times to overlap existing event at end" do
	  	r.start_at = 3.hour.ago
			r.end_at = 1.hours.ago
	  	r.should_not be_valid
	  end
	  
	  it "times to overlap entire existing event" do
	  	r.start_at = 5.hour.ago
			r.end_at = 1.hours.ago
	  	r.should_not be_valid
	  end
	  
	  it "times to overlap existing event as a subset" do
	  	r.start_at = 3.hour.ago
			r.end_at = 3.hours.ago + 30.minutes
	  	r.should_not be_valid
	  end
	  
	  it "times with no overlap of existing event" do
	  	r.start_at = 1.hour.ago
			r.end_at = 30.minutes.ago
	  	r.should be_valid
	  end
	  
	  it "times to overlap of exactly" do
			r.start_at = existing_rehearsal.start_at
			r.end_at = existing_rehearsal.end_at
	  	r.should_not be_valid
	  end
	end
	
  context "(Associations)" do
		it "has one account" do
			rehearsal.reload.account.should == account
		end
		
		it "has one location" do
			rehearsal.reload.location.should == location
		end
		
		it "has one piece" do
			rehearsal.reload.piece.should == piece
		end
  end
  
	context "correct value is returned for" do
		it "title" do
	  	rehearsal.reload.title.should == 'Test Event'
	  end
	  
	  it "type" do
	  	rehearsal.reload.type.should == 'Rehearsal'
	  end
	  
	  it "start_at" do
			rehearsal.reload.start_at.to_s(:db).should == event_start.to_s(:db)
	  end
	  
	  it "end_at" do
			rehearsal.reload.end_at.to_s(:db).should == (event_start+1.hour).to_s(:db)
	  end
  end

	describe "(Scopes)" do
		before do
			account.events.delete_all
		end
		let!(:second_rehearsal) { FactoryGirl.create(:rehearsal, account: account, 
															start_at: 4.hours.ago, end_at: 4.hours.ago + 30.minutes) }
		let!(:first_rehearsal) { FactoryGirl.create(:rehearsal, account: account, 
															start_at: 5.hours.ago, end_at: 5.hours.ago + 30.minutes) }
		let!(:location_wrong_acnt) { FactoryGirl.create(:rehearsal) }
		
		describe "default_scope" do	
			it "returns the records in chronological order by start" do
				Rehearsal.all.should == [first_rehearsal, second_rehearsal]
			end
		end
		
		describe "for_daily_calendar" do
			# For December 3, 2012
			let!(:prev_day_bad) { FactoryGirl.create(:rehearsal, account: account, start_at: "2012-12-02 09:00:00") }
			let!(:current_day_good) { FactoryGirl.create(:rehearsal, account: account, start_at: "2012-12-03 00:00:00") }
			let!(:current_day_wrong_acnt) { FactoryGirl.create(:rehearsal, start_at: "2012-12-03 09:00:00") }
			let!(:current_day_good2) { FactoryGirl.create(:rehearsal, account: account, start_at: "2012-12-03 15:00:00") }
			let!(:current_day_good3) { FactoryGirl.create(:rehearsal, account: account, start_at: "2012-12-03 11:00:00") }
			let!(:wrong_day_bad) { FactoryGirl.create(:rehearsal, account: account, start_at: "2013-01-06 09:00:00") }
			
			it "returns the records for the day" do
				Rehearsal.for_daily_calendar(DateTime.parse("2012-12-3 01:00:00")).should == [current_day_good, current_day_good3, current_day_good2]
			end
		end
		
		describe "for_monthly_calendar" do
			# Dates for December 2012
			let!(:prev_month_bad) { FactoryGirl.create(:rehearsal, account: account, start_at: "2012-11-14 09:00:00") }
			let!(:prev_month_good) { FactoryGirl.create(:rehearsal, account: account, start_at: "2012-11-25 09:00:00") }
			let!(:prev_month_good2) { FactoryGirl.create(:rehearsal, account: account, start_at: "2012-11-26 09:00:00") }
			let!(:current_month_good) { FactoryGirl.create(:rehearsal, account: account, start_at: "2012-12-01 09:00:00") }
			let!(:current_month_wrong_acnt) { FactoryGirl.create(:rehearsal, start_at: "2012-12-01 09:00:00") }
			let!(:current_month_good2) { FactoryGirl.create(:rehearsal, account: account, start_at: "2012-12-15 09:00:00") }
			let!(:current_month_good3) { FactoryGirl.create(:rehearsal, account: account, start_at: "2012-12-31 09:00:00") }
			let!(:next_month_good) { FactoryGirl.create(:rehearsal, account: account, start_at: "2013-01-01 09:00:00") }
			let!(:next_month_good2) { FactoryGirl.create(:rehearsal, account: account, start_at: "2013-01-05 09:00:00") }
			let!(:next_month_bad) { FactoryGirl.create(:rehearsal, account: account, start_at: "2013-01-06 09:00:00") }
			
			it "returns the records for the month plus days from previous/future month that would appear on a calendar" do
				Rehearsal.for_monthly_calendar(DateTime.parse("2012-12-7 09:00:00")).should == [prev_month_good, prev_month_good2, current_month_good, current_month_good2, current_month_good3, next_month_good, next_month_good2]
			end
		end
	end
end