# == Schema Information
#
# Table name: seasons
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  name       :string(30)       not null
#  start_dt   :date             not null
#  end_dt     :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Season do
	let(:account) { FactoryGirl.create(:account) }
	let(:season) { FactoryGirl.create(:season,
											account: account,
											name: '2012-2013 Season',
											start_dt: Date.new(2012,8,1),
											end_dt: Date.new(2013,5,30)
											) }
	before do
		Account.current_id = account.id
		@season = FactoryGirl.build(:season)
	end
	
	subject { @season }
	
	context "accessible attributes" do
		it { should respond_to(:name) }
		it { should respond_to(:start_dt) }
		it { should respond_to(:end_dt) }
  	
  	it { should respond_to(:account) }
  	
  	it "should not allow access to account_id" do
      expect do
        Season.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { season.update_attribute(:account_id, new_account.id) }
			
			it { season.reload.account_id.should == account.id }
		end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end
  
  context "(Invalid)" do
  	it "when name is blank" do
  		@season.name = " "
  		should_not be_valid
  	end
  	
  	it "when name is too long" do
  		@season.name = "a"*31
  		should_not be_valid
  	end
  	
  	it "when start_dt is blank" do
  		@season.start_dt = ""
  		should_not be_valid
  	end
  	
  	it "when start_dt is invalid date" do
  		dts = ["abc", "2/31/2012"]
  		dts.each do |invalid_date|
  			@season.start_dt = invalid_date
  			should_not be_valid
  		end
  	end
  	
  	it "when end_dt is blank" do
  		@season.end_dt = ""
  		should_not be_valid
  	end
  	
  	it "when end_dt is invalid date" do
  		dts = ["abc", "2/31/2012"]
  		dts.each do |invalid_date|
  			@season.end_dt = invalid_date
  			should_not be_valid
  		end
  	end
  	
  	it "when end_dt same as start_dt" do
			@season.start_dt = Time.zone.today
			@season.end_dt = @season.start_dt
	  	should_not be_valid
	  end
	  
		it "when end_dt is before start_dt" do
			@season.start_dt = Time.zone.today
			@season.end_dt = @season.start_dt - 2.days
	  	should_not be_valid
	  end
  end
  
	context "(Associations)" do
  	it "has one account" do
			season.reload.account.should == account
		end
  end
  
	context "correct value is returned for" do
		it "name" do
	  	season.reload.name.should == '2012-2013 Season'
	  end
	  
	  it "start_dt" do
	  	season.reload.start_dt.should == Date.new(2012,8,1)
	  end
	  
	  it "end_dt" do
	  	season.reload.end_dt.should == Date.new(2013,5,30)
	  end
	end

	describe "(Scopes)" do
		before do
			account.seasons.delete_all
		end
		let!(:second_season) { FactoryGirl.create(:season, account: account, start_dt: Date.new(2012,8,1), end_dt: Date.new(2012,10,1)) }
		let!(:first_season) { FactoryGirl.create(:season, account: account, start_dt: Date.new(2012,3,1), end_dt: Date.new(2012,7,1)) }
		let!(:season_wrong_acnt) { FactoryGirl.create(:season) }
		
		describe "default_scope" do
			it "returns the records in start_dt order (most recent first)" do
				Season.all.should == [second_season, first_season]
			end
			
			it "only shows records for current account" do
				Season.all.should_not include(season_wrong_acnt)
			end
		end
		
#		describe "with_date" do
#			it "returns season where date is between the start and end dates" do
#				Season.with_date(Date.new(2012,9,1)).should == [second_season]
#			end
#		end
	end
end

