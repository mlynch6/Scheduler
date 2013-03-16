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
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

require 'spec_helper'

describe AgmaProfile do
  let(:account) { FactoryGirl.create(:account) }
	
	before do
		Account.current_id = account.id
		@profile = FactoryGirl.build(:agma_profile)
	end
	
	subject { @profile }

	context "accessible attributes" do
		it { should respond_to(:rehearsal_start) }
  	it { should respond_to(:rehearsal_end) }
  	it { should respond_to(:rehearsal_max_hrs_per_week) }
  	it { should respond_to(:rehearsal_max_hrs_per_day) }
  	it { should respond_to(:rehearsal_increment_min) }
  	
  	it { should respond_to(:account) }
  	
  	it "should not allow access to account_id" do
      expect do
        AgmaProfile.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
    	let(:profile) { FactoryGirl.create(:agma_profile, account: account) }
			let(:new_account) { FactoryGirl.create(:account) }
			before { profile.update_attribute(:account_id, new_account.id) }
			
			it { profile.reload.account_id.should == account.id }
		end
  end
	
  context "(Valid)" do
  	it "with minimum attributes" do
  		should be_valid
  	end
  end

	context "(Invalid)" do
		it "when rehearsal_start is blank" do
			@profile.rehearsal_start = " "
			should_not be_valid
		end
		
		it "when rehearsal_start is invalid time" do
			tms = ["abc", "8", "25:00"]
  		tms.each do |invalid_time|
  			@profile.rehearsal_start = invalid_time
  			should_not be_valid
  		end
		end
  	
		it "when rehearsal_end is blank" do
  		@profile.rehearsal_end = " "
  		should_not be_valid
  	end
  	
  	it "when rehearsal_end is invalid time" do
			tms = ["abc", "8", "25:00"]
  		tms.each do |invalid_time|
  			@profile.rehearsal_end = invalid_time
  			should_not be_valid
  		end
		end
  	
  	it "when rehearsal_end same as rehearsal_start" do
			@profile.rehearsal_start = 2.hours.ago.to_s(:hr12)
			@profile.rehearsal_end = @profile.rehearsal_start
	  	should_not be_valid
	  end
	  
		it "when rehearsal_end is before rehearsal_start" do
			@profile.rehearsal_start = 1.hour.ago.to_s(:hr12)
			@profile.rehearsal_end = 2.hours.ago.to_s(:hr12)
	  	should_not be_valid
	  end
  	
		it "when rehearsal_max_hrs_per_week is blank" do
  		@profile.rehearsal_max_hrs_per_week = " "
  		should_not be_valid
  	end
  	
  	it "when rehearsal_max_hrs_per_week not an integer" do
  		vals = ["abc", 8.6]
  		vals.each do |invalid_integer|
  			@profile.rehearsal_max_hrs_per_week = invalid_integer
  			should_not be_valid
  		end
  	end
  	
		it "when rehearsal_max_hrs_per_week < 0" do
  		@profile.rehearsal_max_hrs_per_week = -1
  		should_not be_valid
  	end
  	
  	it "when rehearsal_max_hrs_per_week = 0" do
  		@profile.rehearsal_max_hrs_per_week = 0
  		should_not be_valid
  	end
  	
  	it "when rehearsal_max_hrs_per_week > 168 (max hours in a week)" do
  		@profile.rehearsal_max_hrs_per_week = 169
  		should_not be_valid
  	end
  	
  	it "when rehearsal_max_hrs_per_day is blank" do
  		@profile.rehearsal_max_hrs_per_day = " "
  		should_not be_valid
  	end
  	
  	it "when rehearsal_max_hrs_per_day not an integer" do
  		vals = ["abc", 8.6]
  		vals.each do |invalid_integer|
  			@profile.rehearsal_max_hrs_per_day = invalid_integer
  			should_not be_valid
  		end
  	end
  	
		it "when rehearsal_max_hrs_per_day < 0" do
  		@profile.rehearsal_max_hrs_per_day = -1
  		should_not be_valid
  	end
  	
  	it "when rehearsal_max_hrs_per_day = 0" do
  		@profile.rehearsal_max_hrs_per_day = 0
  		should_not be_valid
  	end
  	
  	it "when rehearsal_max_hrs_per_day > 24 (max hours in a day)" do
  		@profile.rehearsal_max_hrs_per_day = 25
  		should_not be_valid
  	end
  	
  	it "when rehearsal_increment_min is blank" do
  		@profile.rehearsal_increment_min = " "
  		should_not be_valid
  	end
  	
  	it "when rehearsal_increment_min not an integer" do
  		vals = ["abc", 8.6]
  		vals.each do |invalid_integer|
  			@profile.rehearsal_increment_min = invalid_integer
  			should_not be_valid
  		end
  	end
  	
		it "when rehearsal_increment_min < 0" do
  		@profile.rehearsal_increment_min = -1
  		should_not be_valid
  	end
  	
  	it "when rehearsal_increment_min = 0" do
  		@profile.rehearsal_increment_min = 0
  		should_not be_valid
  	end
  	
  	it "when rehearsal_increment_min > 144 (6 hrs)" do
  		@profile.rehearsal_increment_min = 145
  		should_not be_valid
  	end
	end
	
	context "(Uniqueness)" do
		describe "account_id" do
			let(:profile) { FactoryGirl.create(:agma_profile, account: account) }
			
			it "has only 1 profile per account" do
	  		@profile = profile.dup
	  		should_not be_valid
	  	end
	  end
  end
	
  context "(Associations)" do
  	let!(:profile) { FactoryGirl.create(:agma_profile, account: account) }
		
		it "has one account" do
			profile.reload.account.should == account
		end
  end
  
	context "correct value is returned for" do
		let(:profile) { FactoryGirl.create(:agma_profile,
											account: account,
											rehearsal_start: '9 AM',
											rehearsal_end: '5 PM',
											rehearsal_max_hrs_per_week: 30,
											rehearsal_max_hrs_per_day: 6,
											rehearsal_increment_min: 15) }
		
		it "rehearsal_start" do
	  	profile.reload.rehearsal_start.to_s(:hr12).should == ' 9:00 AM'
	  end
	  
	  it "rehearsal_end" do
	  	profile.reload.rehearsal_end.to_s(:hr12).should == ' 5:00 PM'
	  end
	  
	  it "rehearsal_max_hrs_per_week" do
			profile.reload.rehearsal_max_hrs_per_week.should == 30
	  end
	  
	  it "rehearsal_max_hrs_per_day" do
			profile.reload.rehearsal_max_hrs_per_day.should == 6
	  end
	  
	  it "rehearsal_increment_min" do
			profile.reload.rehearsal_increment_min.should == 15
	  end
  end

	describe "(Scopes)" do
		let!(:profile) { FactoryGirl.create(:agma_profile, account: account) }
		let!(:profile_wrong_acnt) { FactoryGirl.create(:agma_profile) }
		
		describe "default_scope" do	
			it "returns the profile for current account" do
				AgmaProfile.all.should == [profile]
			end
		end
	end
end
