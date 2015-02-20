require 'spec_helper'

describe Warnings do
	context "LocationDoubleBooked" do
		before do
			@account = FactoryGirl.create(:account)
			Account.current_id = @account.id
		
			@location = FactoryGirl.create(:location, account: @account)
			@rehearsal = FactoryGirl.create(:rehearsal, account: @account)
			@event = FactoryGirl.create(:event, account: @account,
						schedulable: @rehearsal,
						location: @location,
						start_date: Time.zone.today,
						start_time: '10 AM',
						duration: 60)
		end
		
		it "#start_date should return the warning's date" do
			@warning = Warnings::LocationDoubleBooked.new(Time.zone.today)
			@warning.start_date.should == Time.zone.today
		end
		
		describe "with non-overlapping event in a different location" do
			before do
				@location2 = FactoryGirl.create(:location, account: @account)
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@non_overlapping = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							location: @location2,
							start_date: Time.zone.today,
							start_time: '10 AM',
							duration: 60)
				@warning = Warnings::LocationDoubleBooked.new(Time.zone.today)
			end
			
			it "#events should be nil" do
				@warning.events.should be_nil
			end
			
			it "#messages should be nil" do
				@warning.messages.should be_nil
			end
		end
		
		describe "with non-overlapping event adjacent to the event's start" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@non_overlapping = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							location: @location,
							start_date: Time.zone.today,
							start_time: '9 AM',
							duration: 60)
				@warning = Warnings::LocationDoubleBooked.new(Time.zone.today)
			end
			
			it "#events should be nil" do
				@warning.events.should be_nil
			end
			
			it "#messages should be nil" do
				@warning.messages.should be_nil
			end
		end
		
		describe "with non-overlapping event adjacent to the event's end" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@non_overlapping = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							location: @location,
							start_date: Time.zone.today,
							start_time: '11 AM',
							duration: 60)
				@warning = Warnings::LocationDoubleBooked.new(Time.zone.today)
			end
			
			it "#events should be nil" do
				@warning.events.should be_nil
			end
			
			it "#messages should be nil" do
				@warning.messages.should be_nil
			end
		end
		
		describe "with overlap at beginning of event" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@overlapping = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							location: @location,
							start_date: Time.zone.today,
							start_time: '9:30 AM',
							duration: 60)
				@rehearsal3 = FactoryGirl.create(:rehearsal, account: @account)
				@non_overlapping = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal3,
							location: @location,
							start_date: Time.zone.today,
							start_time: '11 AM',
							duration: 60)
				@warning = Warnings::LocationDoubleBooked.new(Time.zone.today)
			end
			
			it "#events should list events with the location overbooked" do
				events = @warning.events
				
				events.size.should == 2
				events.should include @event
				events.should include @overlapping
			end
			
			it "#messages should list warning messages" do
				messages = @warning.messages
				
				messages.size.should == 1
				msg = messages.first
				
				msg.include?("#{@location.name} is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@overlapping.title} ( 9:30 AM to 10:30 AM )").should be_true
			end
		end
		
		describe "with overlap at end of event" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@overlapping = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							location: @location,
							start_date: Time.zone.today,
							start_time: '10:30 AM',
							duration: 60)
				@rehearsal3 = FactoryGirl.create(:rehearsal, account: @account)
				@non_overlapping = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal3,
							location: @location,
							start_date: Time.zone.today,
							start_time: '11:30 AM',
							duration: 60)
				@warning = Warnings::LocationDoubleBooked.new(Time.zone.today)
			end
			
			it "#events should list events with the location overbooked" do
				events = @warning.events
				
				events.size.should == 2
				events.should include @event
				events.should include @overlapping
			end
			
			it "#messages should list warning messages" do
				messages = @warning.messages
				
				messages.size.should == 1
				msg = messages.first
				
				msg.include?("#{@location.name} is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@overlapping.title} ( 10:30 AM to 11:30 AM )").should be_true
			end
		end
		
		describe "with overlap a subset of event" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@overlapping = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							location: @location,
							start_date: Time.zone.today,
							start_time: '10:15 AM',
							duration: 30)
				@rehearsal3 = FactoryGirl.create(:rehearsal, account: @account)
				@non_overlapping = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal3,
							location: @location,
							start_date: Time.zone.today,
							start_time: '11:30 AM',
							duration: 60)
				@warning = Warnings::LocationDoubleBooked.new(Time.zone.today)
			end
			
			it "#events should list events with the location overbooked" do
				events = @warning.events
				
				events.size.should == 2
				events.should include @event
				events.should include @overlapping
			end
			
			it "#messages should list warning messages" do
				messages = @warning.messages
				
				messages.size.should == 1
				msg = messages.first
				
				msg.include?("#{@location.name} is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@overlapping.title} ( 10:15 AM to 10:45 AM )").should be_true
			end
		end
		
		describe "with overlap a superset of event" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@overlapping = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							location: @location,
							start_date: Time.zone.today,
							start_time: '9:45 AM',
							duration: 60)
				@rehearsal3 = FactoryGirl.create(:rehearsal, account: @account)
				@non_overlapping = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal3,
							location: @location,
							start_date: Time.zone.today,
							start_time: '11:30 AM',
							duration: 60)
				@warning = Warnings::LocationDoubleBooked.new(Time.zone.today)
			end
			
			it "#events should list events with the location overbooked" do
				events = @warning.events
				
				events.size.should == 2
				events.should include @event
				events.should include @overlapping
			end
			
			it "#messages should list warning messages" do
				messages = @warning.messages
				
				messages.size.should == 1
				msg = messages.first
				
				msg.include?("#{@location.name} is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@overlapping.title} ( 9:45 AM to 10:45 AM )").should be_true
			end
		end
		
		describe "with overlap of the exact event times" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@overlapping = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							location: @location,
							start_date: Time.zone.today,
							start_time: '10 AM',
							duration: 60)
				@rehearsal3 = FactoryGirl.create(:rehearsal, account: @account)
				@non_overlapping = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal3,
							location: @location,
							start_date: Time.zone.today,
							start_time: '11:30 AM',
							duration: 60)
				@warning = Warnings::LocationDoubleBooked.new(Time.zone.today)
			end
			
			it "#events should list events with the location overbooked" do
				events = @warning.events
				
				events.size.should == 2
				events.should include @event
				events.should include @overlapping
			end
			
			it "#messages should list warning messages" do
				messages = @warning.messages
				
				messages.size.should == 1
				msg = messages.first
				
				msg.include?("#{@location.name} is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@overlapping.title} ( 10:00 AM to 11:00 AM )").should be_true
			end
		end
		
	end
end