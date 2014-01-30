# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
#  title           :string(30)       not null
#  type            :string(20)       default("Event"), not null
#  location_id     :integer          not null
#  start_at        :datetime         not null
#  end_at          :datetime         not null
#  piece_id        :integer
#  event_series_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'
require 'application_helper'

describe Rehearsal do
	let(:account) { FactoryGirl.create(:account) }
	let(:contract) { account.agma_profile }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:piece) { FactoryGirl.create(:piece, account: account) }
	let(:rehearsal) { FactoryGirl.create(:rehearsal,
											account: account,
											location: location,
											title: 'Test Rehearsal',
											start_date: Date.new(2012,1,1),
											start_time: "9AM",
											duration: 60,
											piece: piece) }
	before do
		Account.current_id = account.id
		@rehearsal = FactoryGirl.build(:rehearsal)
	end
	
	subject { @rehearsal }

	context "accessible attributes" do
  	it { should respond_to(:piece) }
  	it { should respond_to(:break_time) }
  	it { should respond_to(:break_duration) }
  	
    it "should allow access to piece_id" do
      expect do
        Rehearsal.new(piece_id: piece.id)
      end.not_to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
	
  context "(Valid)" do
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "when start_time is the same as rehearsal_start" do
  		@rehearsal.start_time = contract.rehearsal_start_time
  		@rehearsal.duration = 60
  		should be_valid
  	end
  	
  	it "when end_time is the same as rehearsal_end" do
  		@rehearsal.start_time = min_to_formatted_time(contract.rehearsal_end_min - 60)
  		@rehearsal.duration = 60
  		should be_valid
  	end
  	
  	it "when duration is a multiple of rehearsal_increment_min" do
  		@rehearsal.start_time = contract.rehearsal_start_time
  		@rehearsal.duration = contract.rehearsal_increment_min
  		should be_valid
  	end
  	
  	it "when start_time is at the end of the Company Class break" do
  		FactoryGirl.create(:company_class,
					account: account,
					start_date: Time.zone.today,
					start_time: contract.rehearsal_start_time,
					duration: 60)
					
			@rehearsal.start_date = Time.zone.today
  		@rehearsal.start_time = min_to_formatted_time(contract.rehearsal_start_min + 60 + contract.class_break_min)
  		@rehearsal.duration = contract.rehearsal_increment_min
  		should be_valid
  	end
  end
  
  context "(Invalid)" do
		it "when piece is blank" do
  		@rehearsal.piece_id = " "
  		should_not be_valid
  	end
  	
  	it "when duration is NOT multiple of rehearsal_increment_min" do
  		@rehearsal.start_time = min_to_formatted_time(contract.rehearsal_start_min)
  		@rehearsal.duration = contract.rehearsal_increment_min - 5
  		should_not be_valid
  	end
  	
  	it "when start_time is before rehearsal_start" do
  		@rehearsal.start_time = min_to_formatted_time(contract.rehearsal_start_min - 15)
  		@rehearsal.duration = contract.rehearsal_increment_min
  		should_not be_valid
  	end
  	
  	it "when end_time is after AgmaProfile rehearsal_end" do
  		@rehearsal.start_time = min_to_formatted_time(contract.rehearsal_end_min - 5)
  		@rehearsal.duration = contract.rehearsal_increment_min
  		should_not be_valid
  	end
  	
  	describe "when start_time" do
  		let!(:company_class) { FactoryGirl.create(:company_class,
					account: account,
					start_date: Time.zone.today,
					start_time: min_to_formatted_time(contract.rehearsal_start_min),
					duration: contract.rehearsal_increment_min
					) }
			
  		it "is at the beginning of the Company Class break" do
				@rehearsal.start_date = Time.zone.today
	  		@rehearsal.start_time = company_class.end_time
	  		should_not be_valid
	  	end
  		
  		it "is during the Company Class break" do
				@rehearsal.start_date = Time.zone.today
	  		@rehearsal.start_time = min_to_formatted_time(contract.rehearsal_start_min + contract.rehearsal_increment_min + 5)
	  		should_not be_valid
  		end
  	end
  end
	
  context "(Associations)" do
		it "has one piece" do
			rehearsal.reload.piece.should == piece
		end
  end
  
  context "correct value is returned for" do  
	  it "type" do
	  	rehearsal.reload.type.should == 'Rehearsal'
	  end
	end
	
	context "(Methods)" do
		it "break_time for 1 hr rehearsal" do
			rehearsal.break_time.should == "9:55 AM to 10:00 AM"
		end
		
		it "break_duration for 1 hr rehearsal" do
			rehearsal.break_duration.should == 5
		end
	end
end
