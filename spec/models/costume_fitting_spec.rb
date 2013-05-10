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

describe CostumeFitting do
	let(:account) { FactoryGirl.create(:account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:fitting) { FactoryGirl.create(:costume_fitting,
											account: account,
											location: location,
											title: 'My Costume Fitting',
											start_date: Date.new(2012,1,1),
											start_time: "9AM",
											end_time: "10AM") }
	before do
		Account.current_id = account.id
		profile = account.agma_profile
  	profile.costume_increment_min = 10
  	profile.save
		@fitting = FactoryGirl.build(:costume_fitting)
	end
	
	subject { @fitting }
	
  context "(Valid)" do
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "without a title - title will be defaulted to 'Costume Fitting'" do
  		fitting.title = ""
  		fitting.save
  		fitting.reload.title.should == "Costume Fitting"
  	end
  	
  	it "when duration is a multiple of AgmaProfile costume_increment_min" do
  		@fitting.start_time = "4PM"
  		@fitting.end_time = "4:10 PM"
  		should be_valid
  	end
  end
  
  context "(Invalid)" do  	
  	it "when duration is NOT multiple of AgmaProfile costume_increment_min" do
  		@fitting.start_time = "4PM"
  		@fitting.end_time = "4:15 PM"
  		should_not be_valid
  	end
  end
  
  context "correct value is returned for" do  
	  it "type" do
	  	fitting.reload.type.should == 'CostumeFitting'
	  end
	end
end
