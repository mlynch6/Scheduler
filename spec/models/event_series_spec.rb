# == Schema Information
#
# Table name: event_series
#
#  id         :integer          not null, primary key
#  period     :string(20)       not null
#  start_at   :date             not null
#  end_at     :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe EventSeries do
  let(:account) { FactoryGirl.create(:account) }
  let(:location) { FactoryGirl.create(:location, account: account) }
  let(:series) { FactoryGirl.create(:event_series,
											period: 'Daily',
											start_at: Date.new(2012,1,1),
											end_at: Date.new(2012,1,15),
											title: "Series Event",
											location_id: location.id,
											start_time: "9AM",
											duration: 60) }
	
	before do
		Account.current_id = account.id
		@series = FactoryGirl.build(:event_series)
	end
	
	subject { @series }

	context "accessible attributes" do
		it { should respond_to(:period) }
  	it { should respond_to(:start_at) }
  	it { should respond_to(:end_at) }
  	
  	it { should respond_to(:type) }
  	it { should respond_to(:title) }
  	it { should respond_to(:location_id) }
  	it { should respond_to(:start_time) }
  	it { should respond_to(:duration) }
  	it { should respond_to(:piece_id) }
  	
  	it { should respond_to(:events) }
  end
  
  context "(Valid)" do
		it "with minimum attributes" do
			should be_valid
		end
		
		it "when period is valid" do
  		valid_periods = ["Never", "Daily", "Weekly", "Monthly", "Yearly"]
  		valid_periods.each do |valid_period|
  			@series.period = valid_period
  			should be_valid
  		end
  	end
	end
	
	context "(Invalid)" do
		it "when period is blank" do
			@series.period = " "
			should_not be_valid
		end
  	
		it "when period is too long" do
  		@series.period = "a"*21
  		should_not be_valid
  	end
  	
		it "when period is invalid" do
  		invalid_periods = ["abc"]
  		invalid_periods.each do |invalid_period|
  			@series.period = invalid_period
  			should_not be_valid
  		end
  	end
  	
  	it "when start_at is blank" do
			@series.start_at = " "
			should_not be_valid
		end
  	
  	it "when start_at is invalid" do
  		dts = ["abc", "2/31/2012"]
  		dts.each do |invalid_date|
  			@series.start_at = invalid_date
  			should_not be_valid
  		end
  	end
  	
  	it "when end_at is blank" do
			@series.end_at = " "
			should_not be_valid
		end
  	
  	it "when end_at is invalid" do
  		dts = ["abc", "2/31/2012"]
  		dts.each do |invalid_date|
  			@series.end_at = invalid_date
  			should_not be_valid
  		end
  	end
  	
  	it "when end_at is on start_at" do
  		@series.end_at = @series.start_at
  		should_not be_valid
  	end
  	
  	it "when end_at is before start_at" do
  		@series.end_at = @series.start_at - 1.month
  		should_not be_valid
  	end
  	
  	it "when event fields are invalid" do
			invalid_series = FactoryGirl.build(:event_series,
							period: 'Daily',
							start_at: Date.new(2012,1,1),
							end_at: Date.new(2012,1,5),
							type: 'Rehearsal',
							title: "Invalid Event",
							location_id: location.id,
							start_time: "9AM",
							duration: 60,
							piece_id: nil)
							
			invalid_series.should_not be_valid
		end
	end
	
	context "(On Creation)" do
		describe "with Period=Daily" do
			let(:daily_series) { FactoryGirl.create(:event_series,
										period: 'Daily',
										start_at: Date.new(2012,1,1),
										end_at: Date.new(2012,1,5),
										title: "Series Event",
										location_id: location.id,
										start_time: "9AM",
										duration: 60) }
			
			it "has events created on the correct days" do
				dts = ["01/01/12", "01/02/12", "01/03/12", "01/04/12", "01/05/12"]
				
				daily_series.events.count.should == 5
				daily_series.events.each do |event|
					dts.should include event.start_date
				end
			end
			
			it "has events created with correct values" do
				daily_series.events.each do |event|
					event.title.should == "Series Event"
					event.location.should == location
					event.start_time.should == "9:00 AM"
					event.duration.should == 60
					event.end_time.should == "10:00 AM"
				end
			end
		end
		
		describe "with Period=Weekly" do
			let(:weekly_series) { FactoryGirl.create(:event_series,
										period: 'Weekly',
										start_at: Date.new(2012,1,1),
										end_at: Date.new(2012,2,9),
										title: "Series Event",
										location_id: location.id,
										start_time: "9AM",
										duration: 60) }
			
			it "has events created on the correct days" do
				dts = ["01/01/12", "01/08/12", "01/15/12", "01/22/12", "01/29/12", "02/05/12"]
				
				weekly_series.events.count.should == 6
				weekly_series.events.each do |event|
					dts.should include event.start_date
				end
			end
			
			it "has events created with correct values" do
				weekly_series.events.each do |event|
					event.title.should == "Series Event"
					event.location.should == location
					event.start_time.should == "9:00 AM"
					event.duration.should == 60
					event.end_time.should == "10:00 AM"
				end
			end
		end
		
		describe "with Period=Monthly" do
			let(:monthly_series) { FactoryGirl.create(:event_series,
										period: 'Monthly',
										start_at: Date.new(2012,1,31),
										end_at: Date.new(2012,5,29),
										title: "Series Event",
										location_id: location.id,
										start_time: "9AM",
										duration: 60) }
			
			it "has events created on the correct days" do
				dts = ["01/31/12", "02/29/12", "03/31/12", "04/30/12"]
				
				monthly_series.events.count.should == 4
				monthly_series.events.each do |event|
					dts.should include event.start_date
				end
			end
			
			it "has events created with correct values" do
				monthly_series.events.each do |event|
					event.title.should == "Series Event"
					event.location.should == location
					event.start_time.should == "9:00 AM"
					event.duration.should == 60
					event.end_time.should == "10:00 AM"
				end
			end
		end
		
		describe "with Period=Yearly" do
			let(:yearly_series) { FactoryGirl.create(:event_series,
										period: 'Yearly',
										start_at: Date.new(2012,1,31),
										end_at: Date.new(2014,5,29),
										title: "Series Event",
										location_id: location.id,
										start_time: "9AM",
										duration: 60) }
			
			it "has events created on the correct days" do
				dts = ["01/31/12", "01/31/13", "01/31/14"]
				
				yearly_series.events.count.should == 3
				yearly_series.events.each do |event|
					dts.should include event.start_date
				end
			end
			
			it "has events created with correct values" do
				yearly_series.events.each do |event|
					event.title.should == "Series Event"
					event.location.should == location
					event.start_time.should == "9:00 AM"
					event.duration.should == 60
					event.end_time.should == "10:00 AM"
				end
			end
		end
	end
	
	context "(Associations)" do		
		describe "events" do
			it "has multiple events" do
				series.events.count.should == 15
			end
			
			it "deletes associated events" do
				events = series.events
				series.destroy
				events.each do |event|
					Event.find_by_id(event.id).should be_nil
				end
			end
		end
  end
	
	context "correct value is returned for" do
		it "period" do
	  	series.reload.period.should == 'Daily'
	  end
	  
	  it "start_at" do
			series.reload.start_at.should == Date.new(2012,1,1)
	  end
	  
	  it "end_at" do
			series.reload.end_at.should == Date.new(2012,1,15)
	  end
  end
end
