# == Schema Information
#
# Table name: event_series
#
#  id         :integer          not null, primary key
#  period     :string(20)       not null
#  start_date :date             not null
#  end_date   :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe EventSeries do
  let(:account) { FactoryGirl.create(:account) }
  let(:location) { FactoryGirl.create(:location, account: account) }
  let(:series) { FactoryGirl.create(:event_series,
											period: 'Daily',
											start_date: Date.new(2012,1,1),
											end_date: Date.new(2012,1,15),
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
  	it { should respond_to(:start_date) }
  	it { should respond_to(:end_date) }
  	
  	it { should respond_to(:event_type) }
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
  	
  	it "when start_date is blank" do
			@series.start_date = " "
			should_not be_valid
		end
  	
  	it "when start_date is invalid" do
  		dts = ["abc", "2/31/2012"]
  		dts.each do |invalid_date|
  			@series.start_date = invalid_date
  			should_not be_valid
  		end
  	end
  	
  	it "when end_date is blank" do
			@series.end_date = " "
			should_not be_valid
		end
  	
  	it "when end_date is invalid" do
  		dts = ["abc", "2/31/2012"]
  		dts.each do |invalid_date|
  			@series.end_date = invalid_date
  			should_not be_valid
  		end
  	end
  	
  	it "when end_date is on start_date" do
  		@series.end_date = @series.start_date
  		should_not be_valid
  	end
  	
  	it "when end_date is before start_date" do
  		@series.end_date = @series.start_date - 1.month
  		should_not be_valid
  	end
  	
  	it "when event fields are invalid" do
			invalid_series = FactoryGirl.build(:event_series,
							period: 'Daily',
							start_date: Date.new(2012,1,1),
							end_date: Date.new(2012,1,5),
							event_type: 'Rehearsal',
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
										start_date: Date.new(2012,1,1),
										end_date: Date.new(2012,1,5),
										title: "Series Event",
										location_id: location.id,
										start_time: "9AM",
										duration: 60) }
			
			it "has events created on the correct days" do
				dts = ["01/01/2012", "01/02/2012", "01/03/2012", "01/04/2012", "01/05/2012"]
				
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
										start_date: Date.new(2012,1,1),
										end_date: Date.new(2012,2,9),
										title: "Series Event",
										location_id: location.id,
										start_time: "9AM",
										duration: 60) }
			
			it "has events created on the correct days" do
				dts = ["01/01/2012", "01/08/2012", "01/15/2012", "01/22/2012", "01/29/2012", "02/05/2012"]
				
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
										start_date: Date.new(2012,1,31),
										end_date: Date.new(2012,5,29),
										title: "Series Event",
										location_id: location.id,
										start_time: "9AM",
										duration: 60) }
			
			it "has events created on the correct days" do
				dts = ["01/31/2012", "02/29/2012", "03/31/2012", "04/30/2012"]
				
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
										start_date: Date.new(2012,1,31),
										end_date: Date.new(2014,5,29),
										title: "Series Event",
										location_id: location.id,
										start_time: "9AM",
										duration: 60) }
			
			it "has events created on the correct days" do
				dts = ["01/31/2012", "01/31/2013", "01/31/2014"]
				
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
	  
	  it "start_date" do
			series.reload.start_date.should == Date.new(2012,1,1)
	  end
	  
	  it "end_date" do
			series.reload.end_date.should == Date.new(2012,1,15)
	  end
  end
  
  context "(Warnings)" do
		context "when Location is double booked" do
			pending
		end
		
		context "when employee is double booked" do
			pending
		end
	end
end
