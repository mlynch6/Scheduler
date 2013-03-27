# == Schema Information
#
# Table name: agma_profiles
#
#  id                         :integer          not null, primary key
#  account_id                 :integer          not null
#  rehearsal_start            :time             not null
#  rehearsal_end              :time             not null
#  rehearsal_max_hrs_per_week :integer          not null
#  rehearsal_max_hrs_per_day  :integer          not null
#  rehearsal_increment_min    :integer          not null
#  class_break_min            :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

require 'spec_helper'

describe AgmaProfile do
  let(:account) { FactoryGirl.create(:account) }
	
	before do
		Account.current_id = account.id
		@profile = account.agma_profile
	end
	
	subject { @profile }

	context "accessible attributes" do
		it { should respond_to(:rehearsal_start_time) }
  	it { should respond_to(:rehearsal_end_time) }
  	it { should respond_to(:rehearsal_max_hrs_per_week) }
  	it { should respond_to(:rehearsal_max_hrs_per_day) }
  	it { should respond_to(:rehearsal_increment_min) }
  	it { should respond_to(:class_break_min) }
  	
  	it { should respond_to(:account) }
		
		it "should not allow access to rehearsal_start" do
      expect do
        AgmaProfile.new(rehearsal_start: '9 AM')
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    it "should not allow access to rehearsal_end" do
      expect do
        AgmaProfile.new(rehearsal_end: '5 PM')
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
	
  context "(Valid)" do
  	it "with minimum attributes" do
  		should be_valid
  	end
  end

	context "(Invalid)" do
		context "when rehearsal_start_time" do
			it "is blank" do
				@profile.rehearsal_start_time = " "
				should_not be_valid
			end
			
			it "is invalid time" do
				tms = ["abc", "8", "25:00"]
	  		tms.each do |invalid_time|
	  			@profile.rehearsal_start_time = invalid_time
	  			should_not be_valid
	  		end
			end
		end
  	
  	context "when rehearsal_end_time" do
			it "is blank" do
	  		@profile.rehearsal_end_time = " "
	  		should_not be_valid
	  	end
	  	
	  	it "is invalid time" do
				tms = ["abc", "8", "25:00"]
	  		tms.each do |invalid_time|
	  			@profile.rehearsal_end_time = invalid_time
	  			should_not be_valid
	  		end
			end
	  	
	  	it "same as rehearsal_start_time" do
				@profile.rehearsal_start_time = "11AM"
				@profile.rehearsal_end_time = @profile.rehearsal_start_time
		  	should_not be_valid
		  end
		  
			it "is before rehearsal_start_time" do
				@profile.rehearsal_start_time = "11AM"
				@profile.rehearsal_end_time = "10 AM"
		  	should_not be_valid
		  end
		end
  	
  	context "when rehearsal_max_hrs_per_week" do
			it "is blank" do
	  		@profile.rehearsal_max_hrs_per_week = " "
	  		should_not be_valid
	  	end
	  	
	  	it "not an integer" do
	  		vals = ["abc", 8.6]
	  		vals.each do |invalid_integer|
	  			@profile.rehearsal_max_hrs_per_week = invalid_integer
	  			should_not be_valid
	  		end
	  	end
	  	
			it "< 0" do
	  		@profile.rehearsal_max_hrs_per_week = -1
	  		should_not be_valid
	  	end
	  	
	  	it "= 0" do
	  		@profile.rehearsal_max_hrs_per_week = 0
	  		should_not be_valid
	  	end
	  	
	  	it "> 168 (max hours in a week)" do
	  		@profile.rehearsal_max_hrs_per_week = 169
	  		should_not be_valid
	  	end
	  end
  	
  	context "when rehearsal_max_hrs_per_day" do
	  	it "is blank" do
	  		@profile.rehearsal_max_hrs_per_day = " "
	  		should_not be_valid
	  	end
	  	
	  	it "not an integer" do
	  		vals = ["abc", 8.6]
	  		vals.each do |invalid_integer|
	  			@profile.rehearsal_max_hrs_per_day = invalid_integer
	  			should_not be_valid
	  		end
	  	end
	  	
			it "< 0" do
	  		@profile.rehearsal_max_hrs_per_day = -1
	  		should_not be_valid
	  	end
	  	
	  	it "= 0" do
	  		@profile.rehearsal_max_hrs_per_day = 0
	  		should_not be_valid
	  	end
	  	
	  	it "> 24 (max hours in a day)" do
	  		@profile.rehearsal_max_hrs_per_day = 25
	  		should_not be_valid
	  	end
	  end
  	
  	context "when rehearsal_increment_min" do
	  	it "is blank" do
	  		@profile.rehearsal_increment_min = " "
	  		should_not be_valid
	  	end
	  	
	  	it "not an integer" do
	  		vals = ["abc", 8.6]
	  		vals.each do |invalid_integer|
	  			@profile.rehearsal_increment_min = invalid_integer
	  			should_not be_valid
	  		end
	  	end
	  	
			it "< 0" do
	  		@profile.rehearsal_increment_min = -1
	  		should_not be_valid
	  	end
	  	
	  	it "= 0" do
	  		@profile.rehearsal_increment_min = 0
	  		should_not be_valid
	  	end
	  	
	  	it "> 144 (6 hrs)" do
	  		@profile.rehearsal_increment_min = 145
	  		should_not be_valid
	  	end
	  end
  	
  	context "when class_break_min" do
	  	it "is blank" do
	  		@profile.class_break_min = " "
	  		should_not be_valid
	  	end
	  	
	  	it "not an integer" do
	  		vals = ["abc", 8.6]
	  		vals.each do |invalid_integer|
	  			@profile.class_break_min = invalid_integer
	  			should_not be_valid
	  		end
	  	end
	  	
			it "< 0" do
	  		@profile.class_break_min = -1
	  		should_not be_valid
	  	end
	  	
	  	it "= 0" do
	  		@profile.class_break_min = 0
	  		should_not be_valid
	  	end
	  	
	  	it "> 144 (6 hrs)" do
	  		@profile.class_break_min = 145
	  		should_not be_valid
	  	end
	  end
	end
	
	context "(Uniqueness)" do
		describe "account_id" do		
			it "has only 1 profile per account" do
	  		expect do
	        FactoryGirl.create(:agma_profile, account: account)
	      end.to raise_error(ActiveRecord::RecordInvalid)
	  	end
	  end
  end
	
  context "(Associations)" do
		it "has one account" do
			@profile.reload.account.should == account
		end
  end
  
	context "correct value is returned for" do
		it "rehearsal_start" do
			@profile.rehearsal_start_time = "9AM"
			@profile.save
	  	account.agma_profile.rehearsal_start.to_s(:hr12).should == '9:00 AM'
	  end
	  
	  it "rehearsal_start_time" do
	  	@profile.rehearsal_start_time = "9AM"
			@profile.save
	  	account.agma_profile.rehearsal_start_time.should == '9AM'
	  end
	  
	  it "rehearsal_end" do
	  	@profile.rehearsal_end_time = "5 PM"
			@profile.save
	  	account.agma_profile.rehearsal_end.to_s(:hr12).should == '5:00 PM'
	  end
	  
	  it "rehearsal_end_time" do
	  	@profile.rehearsal_end_time = "5 PM"
			@profile.save
	  	account.agma_profile.rehearsal_end_time.should == '5 PM'
	  end
	  
	  it "rehearsal_max_hrs_per_week" do
			@profile.rehearsal_max_hrs_per_week = 30
			@profile.save
	  	account.agma_profile.rehearsal_max_hrs_per_week.should == 30
	  end
	  
	  it "rehearsal_max_hrs_per_day" do
	  	@profile.rehearsal_max_hrs_per_day = 6
			@profile.save
	  	account.agma_profile.rehearsal_max_hrs_per_day.should == 6
	  end
	  
	  it "rehearsal_increment_min" do
			@profile.rehearsal_increment_min = 60
			@profile.save
	  	account.agma_profile.rehearsal_increment_min.should == 60
	  end
	  
	  it "class_break_min" do
			@profile.class_break_min = 15
			@profile.save
	  	account.agma_profile.class_break_min.should == 15
	  end
  end

	describe "(Scopes)" do
		let!(:wrong_acnt) { FactoryGirl.create(:account) }
		
		describe "default_scope" do	
			it "returns the profile for current account" do
				AgmaProfile.all.should == [@profile]
			end
		end
	end
end
