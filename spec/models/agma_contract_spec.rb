# == Schema Information
#
# Table name: agma_contracts
#
#  id                         :integer          not null, primary key
#  account_id                 :integer          not null
#  rehearsal_start_min        :integer          not null
#  rehearsal_end_min          :integer          not null
#  rehearsal_max_hrs_per_week :integer          not null
#  rehearsal_max_hrs_per_day  :integer          not null
#  rehearsal_increment_min    :integer          not null
#  class_break_min            :integer          not null
#  rehearsal_break_min_per_hr :integer          not null
#  costume_increment_min      :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

require 'spec_helper'

describe AgmaContract do
	let(:account) { FactoryGirl.create(:account) }
	
	before do
		Account.current_id = account.id
		@contract = account.agma_contract
	end
	
	subject { @contract }

	context "accessible attributes" do
		it { should respond_to(:rehearsal_start_min) }
		it { should respond_to(:rehearsal_end_min) }
		it { should respond_to(:rehearsal_max_hrs_per_week) }
		it { should respond_to(:rehearsal_max_hrs_per_day) }
		it { should respond_to(:rehearsal_increment_min) }
		it { should respond_to(:class_break_min) }
		it { should respond_to(:rehearsal_break_min_per_hr) }
		it { should respond_to(:costume_increment_min) }
  	
		it { should respond_to(:account) }
  	
		it { should respond_to(:rehearsal_start_time) }
		it { should respond_to(:rehearsal_end_time) }
	end
	
	context "(Valid)" do
		it "with minimum attributes" do
			should be_valid
		end
  	
		it "when class_break_min = 0" do
			@contract.class_break_min = 0
			should be_valid
		end
	end

	context "(Invalid)" do
		context "when rehearsal_start_min" do
			it "is blank" do
				@contract.rehearsal_start_min = " "
				should_not be_valid
			end
			
			it "not an integer" do
				vals = ["abc", 8.6]
				vals.each do |invalid_integer|
					@contract.rehearsal_start_min = invalid_integer
					should_not be_valid
				end
			end
	  	
			it "< 0" do
				@contract.rehearsal_start_min = -1
				should_not be_valid
			end
	  	
			it "> 1439 (max min in a day)" do
				@contract.rehearsal_start_min = 1440
				should_not be_valid
			end
		end
  	
		context "when rehearsal_end_min" do
			it "is blank" do
				@contract.rehearsal_end_min = " "
				should_not be_valid
			end
			
			it "not an integer" do
				vals = ["abc", 8.6]
				vals.each do |invalid_integer|
					@contract.rehearsal_end_min = invalid_integer
					should_not be_valid
				end
			end
	  	
			it "< 0" do
				@contract.rehearsal_end_min = -1
				should_not be_valid
			end
	  	
			it "> 1439 (max min in a day)" do
				@contract.rehearsal_end_min = 1440
				should_not be_valid
			end
	  	
			it "<= rehearsal_start_min" do
				@contract.rehearsal_end_min = @contract.rehearsal_start_min
				should_not be_valid
			end
		end
  	
		context "when rehearsal_max_hrs_per_week" do
			it "is blank" do
				@contract.rehearsal_max_hrs_per_week = " "
				should_not be_valid
			end
	  	
			it "not an integer" do
				vals = ["abc", 8.6]
				vals.each do |invalid_integer|
					@contract.rehearsal_max_hrs_per_week = invalid_integer
					should_not be_valid
				end
			end
	  	
			it "< 0" do
				@contract.rehearsal_max_hrs_per_week = -1
				should_not be_valid
			end
	  	
			it "= 0" do
				@contract.rehearsal_max_hrs_per_week = 0
				should_not be_valid
			end
	  	
			it "> 168 (max hours in a week)" do
				@contract.rehearsal_max_hrs_per_week = 169
				should_not be_valid
			end
		end
  	
		context "when rehearsal_max_hrs_per_day" do
			it "is blank" do
				@contract.rehearsal_max_hrs_per_day = " "
				should_not be_valid
			end
	  	
			it "not an integer" do
				vals = ["abc", 8.6]
				vals.each do |invalid_integer|
					@contract.rehearsal_max_hrs_per_day = invalid_integer
					should_not be_valid
				end
			end
	  	
			it "< 0" do
				@contract.rehearsal_max_hrs_per_day = -1
				should_not be_valid
			end
	  	
			it "= 0" do
				@contract.rehearsal_max_hrs_per_day = 0
				should_not be_valid
			end
	  	
			it "> 24 (max hours in a day)" do
				@contract.rehearsal_max_hrs_per_day = 25
				should_not be_valid
			end
		end
  	
		context "when rehearsal_increment_min" do
			it "is blank" do
				@contract.rehearsal_increment_min = " "
				should_not be_valid
			end
	  	
			it "not an integer" do
				vals = ["abc", 8.6]
				vals.each do |invalid_integer|
					@contract.rehearsal_increment_min = invalid_integer
					should_not be_valid
				end
			end
	  	
			it "< 0" do
				@contract.rehearsal_increment_min = -1
				should_not be_valid
			end
	  	
			it "= 0" do
				@contract.rehearsal_increment_min = 0
				should_not be_valid
			end
	  	
			it "> 144 (6 hrs)" do
				@contract.rehearsal_increment_min = 145
				should_not be_valid
			end
		end
  	
		context "when class_break_min" do
			it "is blank" do
				@contract.class_break_min = " "
				should_not be_valid
			end
	  	
			it "not an integer" do
				vals = ["abc", 8.6]
				vals.each do |invalid_integer|
					@contract.class_break_min = invalid_integer
					should_not be_valid
				end
			end
	  	
			it "< 0" do
				@contract.class_break_min = -1
				should_not be_valid
			end
	  	
			it "> 144 (6 hrs)" do
				@contract.class_break_min = 145
				should_not be_valid
			end
		end
	  
		context "when rehearsal_break_min_per_hr" do
			it "is blank" do
				@contract.rehearsal_break_min_per_hr = " "
				should_not be_valid
			end
	  	
			it "not an integer" do
				vals = ["abc", 8.6]
				vals.each do |invalid_integer|
					@contract.rehearsal_break_min_per_hr = invalid_integer
					should_not be_valid
				end
			end
	  	
			it "< 0" do
				@contract.rehearsal_break_min_per_hr = -1
				should_not be_valid
			end
	  	
			it "> 60 (1 hr)" do
				@contract.rehearsal_break_min_per_hr = 61
				should_not be_valid
			end
		end
	  
		context "when costume_increment_min" do
			it "is blank" do
				@contract.costume_increment_min = " "
				should_not be_valid
			end
	  	
			it "not an integer" do
				vals = ["abc", 8.6]
				vals.each do |invalid_integer|
					@contract.costume_increment_min = invalid_integer
					should_not be_valid
				end
			end
	  	
			it "< 0" do
				@contract.costume_increment_min = -1
				should_not be_valid
			end
	  	
			it "= 0" do
				@contract.costume_increment_min = 0
				should_not be_valid
			end
	  	
			it "> 144 (6 hrs)" do
				@contract.costume_increment_min = 145
				should_not be_valid
			end
		end
	end
	
	context "(Uniqueness)" do
		describe "account_id" do		
			it "has only 1 contract per account" do
				expect do
					FactoryGirl.create(:agma_contract, account: account)
				end.to raise_error(ActiveRecord::RecordInvalid)
			end
		end
	end
	
	context "(Associations)" do
		it "has one account" do
			@contract.reload.account.should == account
		end
	end
  
	context "correct value is returned for" do
		it "rehearsal_start_min" do
			@contract.rehearsal_start_min = 480
			@contract.save
			account.agma_contract.rehearsal_start_min.should == 480
		end
	  
		it "rehearsal_end_min" do
			@contract.rehearsal_end_min = 960
			@contract.save
			account.agma_contract.rehearsal_end_min.should == 960
		end
	  
		it "rehearsal_max_hrs_per_week" do
			@contract.rehearsal_max_hrs_per_week = 40
			@contract.save
			account.agma_contract.rehearsal_max_hrs_per_week.should == 40
		end
	  
		it "rehearsal_max_hrs_per_day" do
			@contract.rehearsal_max_hrs_per_day = 7
			@contract.save
			account.agma_contract.rehearsal_max_hrs_per_day.should == 7
		end
	  
		it "rehearsal_increment_min" do
			@contract.rehearsal_increment_min = 30
			@contract.save
			account.agma_contract.rehearsal_increment_min.should == 30
		end
	  
		it "class_break_min" do
			@contract.class_break_min = 10
			@contract.save
			account.agma_contract.class_break_min.should == 10
		end
	  
		it "rehearsal_break_min_per_hr" do
			@contract.rehearsal_break_min_per_hr = 5
			@contract.save
			account.agma_contract.rehearsal_break_min_per_hr.should == 5
		end
	  
		it "costume_increment_min" do
			@contract.costume_increment_min = 15
			@contract.save
			account.agma_contract.costume_increment_min.should == 15
		end
	end

	context "(Defaults)" do
		let(:account_defaults) { FactoryGirl.create(:account) }
		
		it "defaults the rehearsal_start_min to '540'" do
			account_defaults.agma_contract.rehearsal_start_min.should == 540
		end
	  
		it "defaults the rehearsal_end_min to '1080'" do
			account_defaults.agma_contract.rehearsal_end_min.should == 1080
		end
	  
		it "defaults the rehearsal_max_hrs_per_week to '30'" do
			account_defaults.agma_contract.rehearsal_max_hrs_per_week.should == 30
		end
	  
		it "defaults the rehearsal_max_hrs_per_day to '6'" do
			account_defaults.agma_contract.rehearsal_max_hrs_per_day.should == 6
		end
	  
		it "defaults the rehearsal_increment_min to '30'" do
			account_defaults.agma_contract.rehearsal_increment_min.should == 30
		end
	  
		it "defaults the class_break_min to '15'" do
			account_defaults.agma_contract.class_break_min.should == 15
		end
	  
		it "defaults the rehearsal_break_min_per_hr to '5'" do
			account_defaults.agma_contract.rehearsal_break_min_per_hr.should == 5
		end
	  
		it "defaults the costume_increment_min to '15'" do
			account_defaults.agma_contract.costume_increment_min.should == 15
		end
	end
	
	context "(Methods)" do  
		it "rehearsal_start_time" do
			@contract.rehearsal_start_min = 480
			@contract.save
			account.agma_contract.rehearsal_start_time.should == "8:00 AM"
		end
	  
		it "rehearsal_end_time" do
			@contract.rehearsal_end_min = 960
			@contract.save
			account.agma_contract.rehearsal_end_time.should == "4:00 PM"
		end
	end

	describe "(Scopes)" do
		let!(:wrong_acnt) { FactoryGirl.create(:account) }
		
		describe "default_scope" do	
			it "returns the contract for current account" do
				AgmaContract.all.should == [@contract]
			end
		end
	end
end
