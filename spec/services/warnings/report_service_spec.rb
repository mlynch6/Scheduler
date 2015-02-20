require 'spec_helper'

describe Warnings do
	describe "Report" do
		before do
			@account = FactoryGirl.create(:account)
			Account.current_id = @account.id
			@contract = @account.agma_contract
			@start_date = Date.new(2014,1,1)
		end
		
		describe "#rehearsal_week_artist_over_hours_per_day" do
			context "with NO messages in date range" do
				before do
					@contract.destroy
					@report = Warnings::Report.new(@start_date, @start_date)
				end
			
				it "should be nil" do
					@report.rehearsal_week_artist_over_hours_per_day.should be_nil
				end
			end
			
			context "with messages in date range" do
				before do
					@end_date = @start_date + 1.day
					
					@contract.rehearsal_max_hrs_per_day = 6
					@contract.save
					
					@artist1 = FactoryGirl.create(:person, :artist, account: @account)
					@rehearsal1 = FactoryGirl.create(:rehearsal, account: @account)
					@event1 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal1,
								start_date: @start_date,
								duration: 390)
					FactoryGirl.create(:invitation, account: @account, event: @event1, person: @artist1)
					
					@artist2 = FactoryGirl.create(:person, :artist, account: @account)
					@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
					@event2 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal2,
								start_date: @end_date,
								duration: 390)
					FactoryGirl.create(:invitation, account: @account, event: @event2, person: @artist2)
					
					@report = Warnings::Report.new(@start_date, @end_date)
					@warnings = @report.rehearsal_week_artist_over_hours_per_day
				end
			
				it "returns a hash with date and message" do
					@warnings.size.should == 2
					
					@warnings[@start_date].should == Warnings::ArtistOverHoursPerDay.new(@start_date).messages
					@warnings[@end_date].should == Warnings::ArtistOverHoursPerDay.new(@end_date).messages
				end
			end
		end
		
		describe "#rehearsal_week_artist_over_hours_per_week" do
			context "with NO messages in date range" do
				before do
					@contract.destroy
					@report = Warnings::Report.new(@start_date, @start_date)
				end
			
				it "should be nil" do
					@report.rehearsal_week_artist_over_hours_per_week.should be_nil
				end
			end
			
			context "with messages in date range" do
				before do
					@end_date = @start_date + 1.week
					
					@contract.rehearsal_max_hrs_per_week = 6
					@contract.save
					
					@artist1 = FactoryGirl.create(:person, :artist, account: @account)
					@rehearsal1 = FactoryGirl.create(:rehearsal, account: @account)
					@event1 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal1,
								start_date: @start_date,
								duration: 390)
					FactoryGirl.create(:invitation, account: @account, event: @event1, person: @artist1)
					
					@artist2 = FactoryGirl.create(:person, :artist, account: @account)
					@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
					@event2 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal2,
								start_date: @end_date,
								duration: 390)
					FactoryGirl.create(:invitation, account: @account, event: @event2, person: @artist2)
					
					@report = Warnings::Report.new(@start_date, @end_date)
					@warnings = @report.rehearsal_week_artist_over_hours_per_week
				end
			
				it "returns a hash with date and message" do
					@warnings.size.should == 2
					
					@warnings[@start_date.beginning_of_week].should == Warnings::ArtistOverHoursPerWeek.new(@start_date).messages
					@warnings[@end_date.beginning_of_week].should == Warnings::ArtistOverHoursPerWeek.new(@end_date).messages
				end
			end
		end
		
		describe "#location_double_booked" do
			context "with NO messages in date range" do
				before do
					@contract.destroy
					@report = Warnings::Report.new(@start_date, @start_date)
				end
			
				it "should be nil" do
					@report.location_double_booked.should be_nil
				end
			end
			
			context "with messages in date range" do
				before do
					@end_date = @start_date + 1.day
					
					@location = FactoryGirl.create(:location, account: @account)
					@rehearsal1 = FactoryGirl.create(:rehearsal, account: @account)
					@event1 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal1,
								location: @location,
								start_date: @start_date,
								start_time: '10AM',
								duration: 60)
					
					@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
					@event2 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal2,
								location: @location,
								start_date: @end_date,
								start_time: '10AM',
								duration: 60)
								
					@rehearsal3 = FactoryGirl.create(:rehearsal, account: @account)
					@event3 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal3,
								location: @location,
								start_date: @start_date,
								start_time: '10:30 AM',
								duration: 60)
					
					@rehearsal4 = FactoryGirl.create(:rehearsal, account: @account)
					@event4 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal4,
								location: @location,
								start_date: @end_date,
								start_time: '10:30 AM',
								duration: 60)
					
					@report = Warnings::Report.new(@start_date, @end_date)
					@warnings = @report.location_double_booked
				end
			
				it "returns a hash with date and message" do
					@warnings.size.should == 2
					
					@warnings[@start_date].should == Warnings::LocationDoubleBooked.new(@start_date).messages
					@warnings[@end_date].should == Warnings::LocationDoubleBooked.new(@end_date).messages
				end
			end
		end
		
		describe "#company_class_break_violations" do
			before do
				@end_date = @start_date + 1.day
				
				@contract.class_break_min = 15
				@contract.save
				
				@company_class = FactoryGirl.create(:company_class, :daily,
							account: @account,
							start_date: @start_date.to_s,
							end_date: @end_date.to_s,
							start_time: '10:00 AM',
							duration: 60)
			end
			
			context "with NO messages in date range" do
				before do
					@contract.destroy
					@report = Warnings::Report.new(@start_date, @start_date)
				end
			
				it "should be nil" do
					@report.company_class_break_violations.should be_nil
				end
			end
			
			context "with messages in date range" do
				before do
					@rehearsal1 = FactoryGirl.create(:rehearsal, account: @account)
					@event1 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal1,
								start_date: @start_date,
								start_time: '11:10AM',
								duration: 60)
					
					@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
					@event2 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal2,
								start_date: @end_date,
								start_time: '11:10AM',
								duration: 60)
								
					@rehearsal3 = FactoryGirl.create(:rehearsal, account: @account)
					@event3 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal3,
								start_date: @start_date,
								start_time: '11:30 AM',
								duration: 60)
					
					@rehearsal4 = FactoryGirl.create(:rehearsal, account: @account)
					@event4 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal4,
								start_date: @end_date,
								start_time: '11:30 AM',
								duration: 60)
					
					@report = Warnings::Report.new(@start_date, @end_date)
					@warnings = @report.company_class_break_violations
				end
			
				it "returns a hash with date and message" do
					@warnings.size.should == 2
					
					@warnings[@start_date].should == Warnings::CompanyClassBreak.new(@start_date).messages
					@warnings[@end_date].should == Warnings::CompanyClassBreak.new(@end_date).messages
				end
			end
		end
		
		describe "#person_double_booked" do
			context "with NO messages in date range" do
				before do
					@contract.destroy
					@report = Warnings::Report.new(@start_date, @start_date)
				end
			
				it "should be nil" do
					@report.person_double_booked.should be_nil
				end
			end
			
			context "with messages in date range" do
				before do
					@end_date = @start_date + 1.day
					@person = FactoryGirl.create(:person, account: @account)
					
					@rehearsal1 = FactoryGirl.create(:rehearsal, account: @account)
					@event1 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal1,
								start_date: @start_date,
								start_time: '10AM',
								duration: 60)
					FactoryGirl.create(:invitation, account: @account, 
								event: @event1, 
								person: @person)
					
					@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
					@event2 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal2,
								start_date: @end_date,
								start_time: '10AM',
								duration: 60)
					FactoryGirl.create(:invitation, account: @account, 
								event: @event2,
								person: @person)
								
					@rehearsal3 = FactoryGirl.create(:rehearsal, account: @account)
					@event3 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal3,
								start_date: @start_date,
								start_time: '10:30 AM',
								duration: 60)
					FactoryGirl.create(:invitation, account: @account, 
								event: @event3, 
								person: @person)
					
					@rehearsal4 = FactoryGirl.create(:rehearsal, account: @account)
					@event4 = FactoryGirl.create(:event, account: @account,
								schedulable: @rehearsal4,
								start_date: @end_date,
								start_time: '10:30 AM',
								duration: 60)
					FactoryGirl.create(:invitation, account: @account, 
								event: @event4, 
								person: @person)
					
					@report = Warnings::Report.new(@start_date, @end_date)
					@warnings = @report.person_double_booked
				end
			
				it "returns a hash with date and message" do
					@warnings.size.should == 2
					
					@warnings[@start_date].should == Warnings::PersonDoubleBooked.new(@start_date).messages
					@warnings[@end_date].should == Warnings::PersonDoubleBooked.new(@end_date).messages
				end
			end
		end
		
	end
end