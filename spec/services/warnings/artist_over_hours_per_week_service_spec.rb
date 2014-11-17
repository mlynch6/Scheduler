require 'spec_helper'

describe Warnings do
	describe "ArtistOverHoursPerWeek" do
		before do
			@account = FactoryGirl.create(:account)
			Account.current_id = @account.id
			@contract = @account.agma_contract
		
			@artist1 = FactoryGirl.create(:person, :artist, account: @account)
			@artist2 = FactoryGirl.create(:person, :artist, account: @account)
			@artist3 = FactoryGirl.create(:person, :artist, account: @account)
			@musician1 = FactoryGirl.create(:person, :musician, account: @account)
		
			(Date.new(2014,11,10)..Date.new(2014,11,14)).each do |dt|
				@rehearsal = FactoryGirl.create(:rehearsal, account: @account)
				@event_6hr = FactoryGirl.create(:event, account: @account,
							schedulable: @rehearsal,
							start_date: dt,
							duration: 360)
				FactoryGirl.create(:invitation, account: @account, event: @event_6hr, person: @artist1)
				FactoryGirl.create(:invitation, account: @account, event: @event_6hr, person: @artist2)
				FactoryGirl.create(:invitation, account: @account, event: @event_6hr, person: @artist3)
				FactoryGirl.create(:invitation, account: @account, event: @event_6hr, person: @musician1)
			end
		
			@rehearsal2 = FactoryGirl.create(:rehearsal, account: @account)
			@event_overage = FactoryGirl.create(:event, account: @account,
						schedulable: @rehearsal2,
						start_date: Date.new(2014,11,14),
						duration: 30)
			FactoryGirl.create(:invitation, account: @account, event: @event_overage, person: @artist2)
			FactoryGirl.create(:invitation, account: @account, event: @event_overage, person: @artist3)
			FactoryGirl.create(:invitation, account: @account, event: @event_overage, person: @musician1)
		end
		
		context "without a contract" do
			before do
				@contract.destroy
				@warning = Warnings::ArtistOverHoursPerWeek.new(Time.zone.today)
			end
			
			it "#start_date should return the warning's date" do
				@warning.start_date.should == Time.zone.today
			end
				
			it "#artists should return an empty array" do
				@warning.artists.should == []
			end
			
			it "#messages should be nil" do
				@warning.messages.should be_nil
			end
		end
		
		context "with a contract and rehearsal_max_hrs_per_week is blank" do
			before do
				@contract.rehearsal_max_hrs_per_week = ""
				@contract.save
				@warning = Warnings::ArtistOverHoursPerWeek.new(Time.zone.today)
			end
			
			it "#start_date should return the warning's date" do
				@warning.start_date.should == Time.zone.today
			end
			
			it "#artists should return an empty array" do
				@warning.artists.should == []
			end
			
			it "#messages should be nil" do
				@warning.messages.should be_nil
			end
		end
			
		context "with a contract and rehearsal_max_hrs_per_week is set" do
			before do
				@contract.rehearsal_max_hrs_per_week = 30
				@contract.save
				@warning = Warnings::ArtistOverHoursPerWeek.new(Time.zone.today)
			end
			
			it "#start_date should return the warning's date" do
				@warning.start_date.should == Time.zone.today
			end
			
			it "#artists should return the AGMA Artists who are over the rehearsal hours for the week" do
				artists = @warning.artists

				artists.length.should == 2
				artists.should include @artist2
				artists.should include @artist3
			end
			
			it "#messages should have overworked artists listed" do
				messages = @warning.messages

				messages.length.should == 2
				messages.should include "#{@artist2.full_name} is over the maximum rehearsal allowance of 30 hrs/week by 30 minutes"
				messages.should include "#{@artist3.full_name} is over the maximum rehearsal allowance of 30 hrs/week by 30 minutes"
			end
		end
	end
end