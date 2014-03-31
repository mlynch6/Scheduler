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

describe CostumeFitting do
	let(:account) { FactoryGirl.create(:account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:fitting) { FactoryGirl.create(:costume_fitting,
											account: account,
											location: location,
											title: 'My Costume Fitting',
											start_date: Date.new(2012,1,1),
											start_time: "9AM",
											duration: 60) }
	before do
		Account.current_id = account.id
		contract = account.agma_contract
		contract.costume_increment_min = 10
		contract.save
		@fitting = FactoryGirl.build(:costume_fitting)
	end
	
	subject { @fitting }
	
  context "(Valid)" do
	  	it "with minimum attributes" do
	  		should be_valid
	  		fitting.warnings.count.should == 0
	  	end
	  	
	  	it "without a title - title will be defaulted to 'Costume Fitting'" do
	  		fitting.title = ""
	  		fitting.save
	  		fitting.reload.title.should == "Costume Fitting"
	  	end
	  	
	  	it "when duration is a multiple of costume_increment_min" do
	  		@fitting.start_time = "4PM"
	  		@fitting.duration = 10
	  		should be_valid
	  	end
  end
  
  context "(Invalid)" do  	
	  	it "when duration is NOT multiple of costume_increment_min" do
	  		@fitting.start_time = "4PM"
	  		@fitting.duration = 15
	  		should_not be_valid
	  	end
  end
  
  context "correct value is returned for" do  
	  it "type" do
	  		fitting.reload.type.should == 'CostumeFitting'
	  end
	  
	  it "break?" do
			fitting.break?.should be_false
	  end
	end
end
