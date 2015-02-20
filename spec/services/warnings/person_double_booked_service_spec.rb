require 'spec_helper'

describe Warnings do
	context "PersonDoubleBooked" do
		before do
			@account = FactoryGirl.create(:account)
			Account.current_id = @account.id
		
			@instructor = FactoryGirl.create(:person, :instructor, account: @account, last_name: 'A')
			@musician = FactoryGirl.create(:person, :musician, account: @account, last_name: 'B')
			@artist = FactoryGirl.create(:person, :artist, account: @account, last_name: 'C')
			
			@rehearsal = FactoryGirl.create(:rehearsal, account: @account)
			@event = FactoryGirl.create(:event, account: @account,
						schedulable: @rehearsal,
						start_date: Time.zone.today,
						start_time: '10 AM',
						duration: 60)
			FactoryGirl.create(:invitation, account: @account, 
						event: @event, 
						person: @instructor)
			FactoryGirl.create(:invitation, account: @account, 
						event: @event, 
						person: @musician)
		end
		
		it "#start_date should return the warning's date" do
			@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			@warning.start_date.should == Time.zone.today
		end
		
		describe "with overlapping event for a different person" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@event2 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							start_date: Time.zone.today,
							start_time: '10 AM',
							duration: 60)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @artist)
				@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			end
		
			it "#messages should be nil" do
				@warning.messages.should be_nil
			end
		end
		
		#Event 10AM - 11AM w. @instructor & @musician
		
		describe "when non-overlapping event is entirely before the event" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@event2 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							start_date: Time.zone.today,
							start_time: '8 AM',
							duration: 30)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @instructor)
				@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			end
			
			it "#messages should be nil" do
				@warning.messages.should be_nil
			end
		end
		
		describe "when non-overlapping event ends when the event starts" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@event2 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							start_date: Time.zone.today,
							start_time: '9:30 AM',
							duration: 30)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @instructor)
				@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			end
			
			it "#messages should be nil" do
				@warning.messages.should be_nil
			end
		end
		
		describe "when person's event overlaps the event start" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@event2 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							start_date: Time.zone.today,
							start_time: '9:45 AM',
							duration: 30)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @instructor)
				@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			end
			
			it "#messages should list warning messages" do
				messages = @warning.messages
				messages.size.should == 1
				msg = messages.first
		
				msg.include?(@instructor.full_name).should be_true
				msg.include?("is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@event2.title} ( 9:45 AM to 10:15 AM )").should be_true
			end
		end
		
		describe "when person's event is a subset of the event with the same start" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@event2 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							start_date: Time.zone.today,
							start_time: '10 AM',
							duration: 30)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @instructor)
				@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			end
			
			it "#messages should list warning messages" do
				messages = @warning.messages
				messages.size.should == 1
				msg = messages.first
		
				msg.include?(@instructor.full_name).should be_true
				msg.include?("is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@event2.title} ( 10:00 AM to 10:30 AM )").should be_true
			end
		end
		
		describe "when person's event is a subset of the event" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@event2 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							start_date: Time.zone.today,
							start_time: '10:15 AM',
							duration: 30)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @instructor)
				@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			end
			
			it "#messages should list warning messages" do
				messages = @warning.messages
				messages.size.should == 1
				msg = messages.first
		
				msg.include?(@instructor.full_name).should be_true
				msg.include?("is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@event2.title} ( 10:15 AM to 10:45 AM )").should be_true
			end
		end
		
		describe "when person's event is a subset of the event with the same end" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@event2 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							start_date: Time.zone.today,
							start_time: '10:30 AM',
							duration: 30)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @instructor)
				@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			end
			
			it "#messages should list warning messages" do
				messages = @warning.messages
				messages.size.should == 1
				msg = messages.first
		
				msg.include?(@instructor.full_name).should be_true
				msg.include?("is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@event2.title} ( 10:30 AM to 11:00 AM )").should be_true
			end
		end
		
		describe "when person's event overlaps the event end" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@event2 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							start_date: Time.zone.today,
							start_time: '10:45 AM',
							duration: 30)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @instructor)
				@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			end
			
			it "#messages should list warning messages" do
				messages = @warning.messages
				messages.size.should == 1
				msg = messages.first
				
				msg.include?(@instructor.full_name).should be_true
				msg.include?("is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@event2.title} ( 10:45 AM to 11:15 AM )").should be_true
			end
		end
		
		describe "when person's event starts when the event ends" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@event2 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							start_date: Time.zone.today,
							start_time: '11 AM',
							duration: 30)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @instructor)
				@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			end
			
			it "#messages should be nil" do
				@warning.messages.should be_nil
			end
		end
		
		describe "when person's event is after the event" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@event2 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							start_date: Time.zone.today,
							start_time: '11:15 AM',
							duration: 30)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @instructor)
				@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			end
			
			it "#messages should be nil" do
				@warning.messages.should be_nil
			end
		end
		
		describe "returns true when event is a subset of person's event" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@event2 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							start_date: Time.zone.today,
							start_time: '9:30 AM',
							duration: 120)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @instructor)
				@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			end
			
			it "#messages should list warning messages" do
				messages = @warning.messages
				messages.size.should == 1
				msg = messages.first
				
				msg.include?(@instructor.full_name).should be_true
				msg.include?("is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@event2.title} ( 9:30 AM to 11:30 AM )").should be_true
			end
		end
		
		describe "when multiple people have overlapping event" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@event2 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							start_date: Time.zone.today,
							start_time: '9:45 AM',
							duration: 30)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @instructor)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @musician)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @artist)
				@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			end
			
			it "#messages should list warning messages" do
				messages = @warning.messages
				messages.size.should == 2
				
				msg = messages.first
				msg.include?(@instructor.full_name).should be_true
				msg.include?("is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@event2.title} ( 9:45 AM to 10:15 AM )").should be_true
				
				msg = messages.last
				msg.include?(@musician.full_name).should be_true
				msg.include?("is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@event2.title} ( 9:45 AM to 10:15 AM )").should be_true
			end
		end
		
		describe "when person has multiple overlapping events" do
			before do
				@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
				@event2 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal2,
							start_date: Time.zone.today,
							start_time: '9:45 AM',
							duration: 30)
				FactoryGirl.create(:invitation, account: @account,
							event: @event2,
							person: @instructor)
				
				@rehearsal3 = FactoryGirl.create(:rehearsal, account: @account)
				@event3 = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal3,
							start_date: Time.zone.today,
							start_time: '10 AM',
							duration: 30)
				FactoryGirl.create(:invitation, account: @account,
							event: @event3,
							person: @instructor)
				@warning = Warnings::PersonDoubleBooked.new(Time.zone.today)
			end
			
			it "#messages should list warning messages" do
				messages = @warning.messages
				messages.size.should == 1
				
				msg = messages.first
				msg.include?(@instructor.full_name).should be_true
				msg.include?("is double booked:").should be_true
				msg.include?("#{@event.title} ( 10:00 AM to 11:00 AM )").should be_true
				msg.include?("#{@event2.title} ( 9:45 AM to 10:15 AM )").should be_true
				msg.include?("#{@event3.title} ( 10:00 AM to 10:30 AM )").should be_true
			end
		end
	end
end