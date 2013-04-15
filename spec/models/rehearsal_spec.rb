# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  account_id  :integer          not null
#  title       :string(30)       not null
#  type        :string(20)       not null
#  location_id :integer          not null
#  start_at    :datetime         not null
#  end_at      :datetime         not null
#  piece_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Rehearsal do
	let(:account) { FactoryGirl.create(:account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:piece) { FactoryGirl.create(:piece, account: account) }
	let(:rehearsal) { FactoryGirl.create(:rehearsal,
											account: account,
											location: location,
											title: 'Test Rehearsal',
											start_date: Date.new(2012,1,1),
											start_time: "9AM",
											end_time: "10AM",
											piece: piece) }
	before do
		Account.current_id = account.id
		profile = account.agma_profile
  	profile.rehearsal_start_time = "9AM"
  	profile.rehearsal_end_time = "5PM"
  	profile.rehearsal_increment_min = 30
  	profile.class_break_min = 15
  	profile.save
		@rehearsal = FactoryGirl.build(:rehearsal)
	end
	
	subject { @rehearsal }

	context "accessible attributes" do
  	it { should respond_to(:piece) }
  	
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
  	
  	it "when start_time is the same as AgmaProfile rehearsal_start" do
  		@rehearsal.start_time = "9AM"
  		@rehearsal.end_time = "10AM"
  		should be_valid
  	end
  	
  	it "when end_time is the same as AgmaProfile rehearsal_end" do
  		@rehearsal.start_time = "4PM"
  		@rehearsal.end_time = "5PM"
  		should be_valid
  	end
  	
  	it "when duration is a multiple of AgmaProfile rehearsal_increment_min" do
  		@rehearsal.start_time = "4PM"
  		@rehearsal.end_time = "4:30 PM"
  		should be_valid
  	end
  	
  	it "when start_time is at the end of the Company Class break" do
  		FactoryGirl.create(:company_class,
					account: account,
					start_date: Time.zone.today,
					start_time: "9AM",
					end_time: "10AM")
					
			@rehearsal.start_date = Time.zone.today
  		@rehearsal.start_time = "10:15AM"
  		@rehearsal.end_time = "10:45 AM"
  		should be_valid
  	end
  end
  
  context "(Invalid)" do
		it "when piece is blank" do
  		@rehearsal.piece_id = " "
  		should_not be_valid
  	end
  	
  	it "when duration is NOT multiple of AgmaProfile rehearsal_increment_min" do
  		@rehearsal.start_time = "4PM"
  		@rehearsal.end_time = "4:15 PM"
  		should_not be_valid
  	end
  	
  	it "when start_time is before AgmaProfile rehearsal_start" do
  		@rehearsal.start_time = "8 AM"
  		@rehearsal.end_time = "10 AM"
  		should_not be_valid
  	end
  	
  	it "when end_time is after AgmaProfile rehearsal_end" do
  		@rehearsal.start_time = "4 PM"
  		@rehearsal.end_time = "6 PM"
  		should_not be_valid
  	end
  	
  	describe "when start_time" do
  		let!(:company_class) { FactoryGirl.create(:company_class,
					account: account,
					start_date: Time.zone.today,
					start_time: "9AM",
					end_time: "10AM") }
			
  		it "is at the beginning of the Company Class break" do
				@rehearsal.start_date = Time.zone.today
	  		@rehearsal.start_time = "10AM"
	  		@rehearsal.end_time = "10:30 AM"
	  		should_not be_valid
	  	end
  		
  		it "is during the Company Class break" do
				@rehearsal.start_date = Time.zone.today
	  		@rehearsal.start_time = "10:05 AM"
	  		@rehearsal.end_time = "10:35 AM"
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
end
