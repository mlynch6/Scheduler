# == Schema Information
#
# Table name: event_series
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
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
  										account: account, 
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
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:events) }
  	
  	it { should respond_to(:destroy_event) }
  	
  	it "should not allow access to account_id" do
      expect do
        EventSeries.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { series.update_attribute(:account_id, new_account.id) }
			
			it { series.reload.account_id.should == account.id }
		end
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
							account: account, 
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
										account: account, 
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
										account: account, 
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
										account: account, 
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
										account: account, 
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
  
  describe "(Scopes)" do
		before do
			account.event_series.delete_all
		end
		
		describe "default_scope" do	
			let!(:series1) { FactoryGirl.create(:event_series, account: account) }
			let!(:series2) { FactoryGirl.create(:event_series, account: account) }
			let!(:series3) { FactoryGirl.create(:event_series, account: account) }
			let!(:series_wrong_acnt) { FactoryGirl.create(:event_series, account: FactoryGirl.create(:account)) }
			
			it "returns the records from account only" do
				EventSeries.all.should include(series1)
				EventSeries.all.should include(series2)
				EventSeries.all.should include(series3)
				
				EventSeries.all.should_not include(series_wrong_acnt)
			end
		end
	end
  
  context "(Methods)" do
		context "update_event" do
  		let(:loc2) { FactoryGirl.create(:location, account: account) }
  		let(:p1) { FactoryGirl.create(:person, account: account) }
  		let(:p2) { FactoryGirl.create(:person, account: account) }
  		let(:daily_series) { FactoryGirl.create(:event_series,
						account: account, 
						period: 'Daily',
						start_date: Date.new(2012,1,1),
						end_date: Date.new(2012,1,5),
						title: "Series Event",
						location_id: location.id,
						start_time: "9AM",
						duration: 60) }
			
  		describe "with mode = single" do
  			let(:attrs) { { 
						title: 'Updated Event', 
		  			location_id: loc2.id, 
		  			start_date: '01/07/2012',
		  			start_time: "10AM",
		  			duration: 90,
		  			invitee_ids: [p1.id, p2.id] } }
		  	
  			describe "updating the event fields" do
		  		it "updates the event" do
		  			event = daily_series.events.offset(1).first		#01/02/2012
		  			daily_series.update_event(:single, event, attrs)
		  			
		  			event.title.should == 'Updated Event'
						event.location.should == loc2
						event.start_time.should == '10AM'
						event.duration.should == 90
		  		end
		  		
		  		it "updates the invitees" do
		  			event = daily_series.events.offset(1).first		#01/02/2012
		  			daily_series.update_event(:single, event, attrs)
		  			
		  			event.invitees.count.should == 2
		  			event.invitees.should include(p1)
		  			event.invitees.should include(p2)
		  		end
		  		
		  		it "removes the updated event from Series" do
		  			event = daily_series.events.offset(1).first		#01/02/2012
		  			daily_series.update_event(:single, event, attrs)
		  			
		  			event.event_series_id.should be_nil
		  			
		  			dts = ["01/01/2012", "01/03/2012", "01/04/2012", "01/05/2012"]
						daily_series.events.count.should == 4
						daily_series.events.each do |e|
							dts.should include e.start_date
						end
		  		end
		  		
		  		it "does not update the other repeating events" do
		  			event = daily_series.events.offset(1).first		#01/02/2012
		  			daily_series.update_event(:single, event, attrs)
		  			
		  			daily_series.events.count.should == 4
						daily_series.events.each do |e|
							e.title.should == 'Series Event'
							e.location.should == location
							e.start_time.should == '9:00 AM'
							e.duration.should == 60
						end
		  		end
		  		
		  		it "updates the series start_date when the first event in series has start_date changed" do
		  			event = daily_series.events.first		#01/01/2012
		  			daily_series.update_event(:single, event, attrs)
		  			
		  			daily_series.start_date.should == Date.new(2012,1,2)
		  			daily_series.end_date.should == Date.new(2012,1,5)
		  		end
		  		
		  		it "updates the series end_date when the last event in series has start_date changed" do
				  	event = daily_series.events.last		#01/05/2012
		  			daily_series.update_event(:single, event, attrs)
		  			
		  			daily_series.start_date.should == Date.new(2012,1,1)
		  			daily_series.end_date.should == Date.new(2012,1,4)
					end
		  	end
		  	
		  	describe "updating the repeating fields" do
		  		it "does not create a series for the event" do
		  			attrs = { period: 'Daily' }
		  			event = daily_series.events.offset(1).first		#01/02/2012
		  			daily_series.update_event(:single, event, attrs)
		  			
		  			event.event_series_id.should be_nil
		  		end
		  	end
		  	
		  	it "reports event errors" do
	  			event = daily_series.events.offset(1).first		#01/02/2012
	  			attrs[:title] = ""
	  			daily_series.update_event(:single, event, attrs)
	  			
	  			event.should_not be_valid
	  			daily_series.errors.count.should == 1
	  		end
	  	end
			
			describe "with mode = all" do
				context "when changing event values" do
					it "updates the all events in the series" do
						attrs = { 
							title: 'Updated Event', 
			  			location_id: loc2.id,
			  			start_time: "10AM",
			  			duration: 90, 
			  			invitee_ids: [p1.id, p2.id] }
						event = daily_series.events.offset(1).first		#01/02/2012
			  		daily_series.update_event(:all, event, attrs)
			  		daily_series.reload
			  		
						dts = ["01/01/2012", "01/02/2012", "01/03/2012", "01/04/2012", "01/05/2012"]
						daily_series.events.count.should == 5
						daily_series.events.each do |e|
							e.title.should == 'Updated Event'
							e.location.should == loc2
							dts.should include e.start_date
							e.start_time.should == '10:00 AM'
							e.duration.should == 90
							
							e.invitees.count.should == 2
							e.invitees.should include(p1)
							e.invitees.should include(p2)
						end
					end
				end
				
				context "when changing start_date" do
					it "to before the original start_date, events are added to the series" do
						attrs = { start_date: Date.new(2011, 12, 30) }
						event = daily_series.events.offset(1).first		#01/02/2012
						daily_series.update_event(:all, event, attrs)
						daily_series.reload
						
						dts = ["12/30/2011", "12/31/2011", "01/01/2012", "01/02/2012", "01/03/2012", "01/04/2012", "01/05/2012"]
						
						daily_series.events.count.should == 7
						daily_series.events.each do |e|
							e.title.should == 'Series Event'
							e.location.should == location
							dts.should include e.start_date
							e.start_time.should == '9:00 AM'
							e.duration.should == 60
						end
					end
					
					it "after the original start_date, events are removed the series" do
						attrs = { start_date: Date.new(2012, 1, 3) }
						event = daily_series.events.offset(1).first		#01/02/2012
						daily_series.update_event(:all, event, attrs)
						daily_series.reload
						
						dts = ["01/03/2012", "01/04/2012", "01/05/2012"]
						
						daily_series.events.count.should == 3
						daily_series.events.each do |e|
							e.title.should == 'Series Event'
							e.location.should == location
							dts.should include e.start_date
							e.start_time.should == '9:00 AM'
							e.duration.should == 60
						end
					end
				end
				
				context "when changing end_date" do
					it "after the original end_date, events are added to the series" do
						attrs = { end_date: Date.new(2012, 1, 7) }
						event = daily_series.events.offset(1).first		#01/02/2012
						daily_series.update_event(:all, event, attrs)
						daily_series.reload
						
						dts = ["01/01/2012", "01/02/2012", "01/03/2012", "01/04/2012", "01/05/2012", "01/06/2012", "01/07/2012"]
						
						daily_series.events.count.should == 7
						daily_series.events.each do |e|
							e.title.should == 'Series Event'
							e.location.should == location
							dts.should include e.start_date
							e.start_time.should == '9:00 AM'
							e.duration.should == 60
						end
					end
				
					it "before the original end_date, events are removed from the series" do
						attrs = { end_date: Date.new(2012, 1, 3) }
						event = daily_series.events.offset(1).first		#01/02/2012
						daily_series.update_event(:all, event, attrs)
						daily_series.reload
						
						dts = ["01/01/2012", "01/02/2012", "01/03/2012"]
						
						daily_series.events.count.should == 3
						daily_series.events.each do |e|
							e.title.should == 'Series Event'
							e.location.should == location
							dts.should include e.start_date
							e.start_time.should == '9:00 AM'
							e.duration.should == 60
						end
					end
				end
				
				context "when changing period" do
					it "the series has correct events" do
						attrs = { 
							period: 'Monthly',
							start_date: Date.new(2012, 1, 2),
							end_date: Date.new(2012, 4, 3) }
						event = daily_series.events.offset(1).first		#01/02/2012
						daily_series.update_event(:all, event, attrs)
						daily_series.reload
						
						dts = ["01/02/2012", "02/02/2012", "03/02/2012", "04/02/2012"]
						
						daily_series.events.count.should == 4
						daily_series.events.each do |e|
							e.title.should == 'Series Event'
							e.location.should == location
							dts.should include e.start_date
							e.start_time.should == '9:00 AM'
							e.duration.should == 60
						end
					end
				end
				
				it "reports event errors" do
					attrs = { title: '' }
					event = daily_series.events.offset(1).first		#01/02/2012
			  	daily_series.update_event(:all, event, attrs)
			  	daily_series.reload
		  			
		  		daily_series.errors.count.should == 1
		  	end
			end
			
			describe "with mode = future" do
				let(:weekly_series) { FactoryGirl.create(:event_series,
						account: account, 
						period: 'Weekly',
						start_date: Date.new(2012,1,1),
						end_date: Date.new(2012,1,29),
						title: "Series Event",
						location_id: location.id,
						start_time: "9AM",
						duration: 60) }
			  let(:event) { weekly_series.events.offset(2).first }		#01/15/2012
			  let (:attrs) { {
							title: 'Updated Event', 
			  			location_id: loc2.id,
			  			start_time: "10AM",
			  			duration: 90, 
			  			invitee_ids: [p1.id, p2.id] }
			  		}
			  
				context "when changing event values" do
					before do
						weekly_series.update_event(:future, event, attrs)
						weekly_series.reload
					end
					
					it "does not change past events & removes future events from series" do
						dts = ["01/01/2012", "01/08/2012"]
						
						weekly_series.events.count.should == 2
						weekly_series.events.each do |e|
							e.title.should == 'Series Event'
							e.location.should == location
							dts.should include e.start_date
							e.start_time.should == '9:00 AM'
							e.duration.should == 60
							
							e.invitees.count.should == 0
						end
					end
					
					it "updates end_date of existing series" do
						weekly_series.end_date.should == Date.new(2012, 1, 8)
					end
					
					it "creates a new series with updated future events" do
						new_series = EventSeries.last
						new_series.period.should  == "Weekly"
						new_series.start_date.should  == Date.new(2012, 1, 15)
						new_series.end_date.should  == Date.new(2012, 1, 29)
						
						dts = ["01/15/2012", "01/22/2012", "01/29/2012"]
						new_series.events.count.should == 3
						new_series.events.each do |e|
							e.title.should == 'Updated Event'
							e.location.should == loc2
							dts.should include e.start_date
							e.start_time.should == '10:00 AM'
							e.duration.should == 90
							
							e.invitees.count.should == 2
							e.invitees.should include(p1)
							e.invitees.should include(p2)
						end
					end
				end
				
				context "when changing start_date" do
					before do
						attrs[:start_date] = Date.new(2012, 1, 14)
						weekly_series.update_event(:future, event, attrs)
					end
				
					it "does not change past events & removes future events from series" do
						dts = ["01/01/2012", "01/08/2012"]
						
						weekly_series.events.count.should == 2
						weekly_series.events.each do |e|
							e.title.should == 'Series Event'
							e.location.should == location
							dts.should include e.start_date
							e.start_time.should == '9:00 AM'
							e.duration.should == 60
							
							e.invitees.count.should == 0
						end
					end
					
					it "updates end_date of existing series" do
						weekly_series.end_date.should == Date.new(2012, 1, 8)
					end
					
					it "creates a new series with updated future events" do
						new_series = EventSeries.last
						new_series.period.should  == "Weekly"
						new_series.start_date.should  == Date.new(2012, 1, 14)
						new_series.end_date.should  == Date.new(2012, 1, 29)
						
						dts = ["01/14/2012", "01/21/2012", "01/28/2012"]
						new_series.events.count.should == 3
						new_series.events.each do |e|
							e.title.should == 'Updated Event'
							e.location.should == loc2
							dts.should include e.start_date
							e.start_time.should == '10:00 AM'
							e.duration.should == 90
							
							e.invitees.count.should == 2
							e.invitees.should include(p1)
							e.invitees.should include(p2)
						end
					end
				end
				
				context "when changing end_date" do
					describe "before original end_date," do
						before do
							attrs[:end_date] = Date.new(2012, 1, 24)
							weekly_series.update_event(:future, event, attrs)
						end
						
						it "does not change past events & removes future events from series" do
							dts = ["01/01/2012", "01/08/2012"]
							
							weekly_series.events.count.should == 2
							weekly_series.events.each do |e|
								e.title.should == 'Series Event'
								e.location.should == location
								dts.should include e.start_date
								e.start_time.should == '9:00 AM'
								e.duration.should == 60
								
								e.invitees.count.should == 0
							end
						end
						
						it "updates end_date of existing series" do
							weekly_series.end_date.should == Date.new(2012, 1, 8)
						end
						
						it "creates a new series with updated future events" do
							new_series = EventSeries.last
							new_series.period.should  == "Weekly"
							new_series.start_date.should  == Date.new(2012, 1, 15)
							new_series.end_date.should  == Date.new(2012, 1, 24)
							
							dts = ["01/15/2012", "01/22/2012"]
							new_series.events.count.should == 2
							new_series.events.each do |e|
								e.title.should == 'Updated Event'
								e.location.should == loc2
								dts.should include e.start_date
								e.start_time.should == '10:00 AM'
								e.duration.should == 90
								
								e.invitees.count.should == 2
								e.invitees.should include(p1)
								e.invitees.should include(p2)
							end
						end
					end
					
					describe "after original end_date," do
						before do
							attrs[:end_date] = Date.new(2012, 2, 12)
							weekly_series.update_event(:future, event, attrs)
						end
					
						it "does not change past events & removes future events from series" do
							dts = ["01/01/2012", "01/08/2012"]
							
							weekly_series.events.count.should == 2
							weekly_series.events.each do |e|
								e.title.should == 'Series Event'
								e.location.should == location
								dts.should include e.start_date
								e.start_time.should == '9:00 AM'
								e.duration.should == 60
								
								e.invitees.count.should == 0
							end
						end
						
						it "updates end_date of existing series" do
							weekly_series.end_date.should == Date.new(2012, 1, 8)
						end
						
						it "creates a new series with updated future events" do
							new_series = EventSeries.last
							new_series.period.should  == "Weekly"
							new_series.start_date.should  == Date.new(2012, 1, 15)
							new_series.end_date.should  == Date.new(2012, 2, 12)
							
							dts = ["01/15/2012", "01/22/2012", "01/29/2012", "02/05/2012", "02/12/2012"]
							new_series.events.count.should == 5
							new_series.events.each do |e|
								e.title.should == 'Updated Event'
								e.location.should == loc2
								dts.should include e.start_date
								e.start_time.should == '10:00 AM'
								e.duration.should == 90
								
								e.invitees.count.should == 2
								e.invitees.should include(p1)
								e.invitees.should include(p2)
							end
						end
					end
				end
				
				context "when changing period" do
					before do
						attrs[:period] = 'Daily'
						weekly_series.update_event(:future, event, attrs)
					end
					
					it "does not change past events & removes future events from series" do
						dts = ["01/01/2012", "01/08/2012"]
						
						weekly_series.events.count.should == 2
						weekly_series.events.each do |e|
							e.title.should == 'Series Event'
							e.location.should == location
							dts.should include e.start_date
							e.start_time.should == '9:00 AM'
							e.duration.should == 60
							
							e.invitees.count.should == 0
						end
					end
					
					it "updates end_date of existing series" do
						weekly_series.period.should  == "Weekly"
						weekly_series.end_date.should == Date.new(2012, 1, 8)
					end
					
					it "creates a new series with updated future events" do
						new_series = EventSeries.last
						new_series.period.should  == "Daily"
						new_series.start_date.should  == Date.new(2012, 1, 15)
						new_series.end_date.should  == Date.new(2012, 1, 29)
						
						dts = ["01/15/2012", "01/16/2012", "01/17/2012", "01/18/2012", "01/19/2012", 
									 "01/20/2012", "01/21/2012", "01/22/2012", "01/23/2012", "01/24/2012", 
									 "01/25/2012", "01/26/2012", "01/27/2012", "01/28/2012", "01/29/2012"]
						new_series.events.count.should == 15
						new_series.events.each do |e|
							e.title.should == 'Updated Event'
							e.location.should == loc2
							dts.should include e.start_date
							e.start_time.should == '10:00 AM'
							e.duration.should == 90
							
							e.invitees.count.should == 2
							e.invitees.should include(p1)
							e.invitees.should include(p2)
						end
					end
				end
				
				it "reports event errors" do
					attrs = { title: '' }
			  	weekly_series.update_event(:future, event, attrs)
		  			
		  		weekly_series.errors.count.should == 1
		  	end
			end
  	end
  	
  	context "destroy_event" do
  		let(:daily_series) { FactoryGirl.create(:event_series,
										account: account, 
										period: 'Daily',
										start_date: Date.new(2012,1,1),
										end_date: Date.new(2012,1,5),
										title: "Series Event",
										location_id: location.id,
										start_time: "9AM",
										duration: 60) }
			
  		describe "with mode = single" do
	  		it "deletes the event" do
	  			event = daily_series.events.offset(1).first		#01/02/2012
	  			daily_series.destroy_event(:single, event)
	  			
	  			Event.find_by_id(event.id).should be_nil
	  		end
	  		
	  		it "does not delete the other repeating events" do
	  			event = daily_series.events.offset(1).first		#01/02/2012
	  			daily_series.destroy_event(:single, event)
	  			
	  			dts = ["01/01/2012", "01/03/2012", "01/04/2012", "01/05/2012"]
				
					daily_series.events.count.should == 4
					daily_series.events.each do |e|
						dts.should include e.start_date
					end
	  		end
	  		
	  		it "updates the series start_date when the first event in series is deleted" do
	  			event = daily_series.events.first		#01/01/2012
	  			daily_series.destroy_event(:single, event)
	  			
	  			Event.find_by_id(event.id).should be_nil
	  			daily_series.start_date.should == Date.new(2012,1,2)
	  			daily_series.end_date.should == Date.new(2012,1,5)
	  		end
	  		
	  		it "updates the series end_date when the last event in series is deleted" do
			  	event = daily_series.events.last		#01/05/2012
	  			daily_series.destroy_event(:single, event)
	  			
	  			Event.find_by_id(event.id).should be_nil
	  			daily_series.start_date.should == Date.new(2012,1,1)
	  			daily_series.end_date.should == Date.new(2012,1,4)
				end
			end
			
			describe "with mode = all" do
				let(:event) { daily_series.events.offset(1).first }	#01/02/2012
				let(:events) { daily_series.events }
				
				before do
					daily_series.destroy_event(:all, event)
		  	end
	  			
				it "deletes the series" do
					EventSeries.find_by_id(daily_series.id).should be_nil
				end
				
				it "deletes the all events in the series" do
					events.each do |e|
						Event.find_by_id(e.id).should be_nil
					end
				end
			end
			
			describe "with mode = future" do
				let(:event) { daily_series.events.offset(2).first }	#01/03/2012
				
				before do
					daily_series.destroy_event(:future, event)
				end
				
				it "deletes the event" do
					Event.find_by_id(event.id).should be_nil
				end
				
				it "deletes the repeating events in future" do
					dts = ["01/01/2012", "01/02/2012"]
				
					daily_series.events.count.should == 2
					daily_series.events.each do |e|
						dts.should include e.start_date
					end
				end
				
				it "updates the series end_date" do
	  			daily_series.start_date.should == Date.new(2012,1,1)
	  			daily_series.end_date.should == Date.new(2012,1,2)
				end
			end
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
