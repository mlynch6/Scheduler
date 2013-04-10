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

describe CompanyClass do
	let(:account) { FactoryGirl.create(:account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:cclass) { FactoryGirl.create(:company_class,
											account: account,
											location: location,
											title: 'Class',
											start_date: Date.new(2012,1,1),
											start_time: "9AM",
											end_time: "10AM") }
	before do
		Account.current_id = account.id
		profile = account.agma_profile
  	profile.rehearsal_start_time = "9AM"
  	profile.rehearsal_end_time = "5PM"
  	profile.rehearsal_increment_min = 30
  	profile.save
		@cclass = FactoryGirl.build(:company_class)
	end
	
	subject { @cclass }
	
  context "(Valid)" do
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "without a title - title will be defaulted to 'Company Class'" do
  		cclass.title = ""
  		cclass.save
  		cclass.reload.title.should == "Company Class"
  	end
  	
  	it "when start_time is the same as AgmaProfile rehearsal_start" do
  		@cclass.start_time = "9AM"
  		@cclass.end_time = "10AM"
  		should be_valid
  	end
  	
  	it "when end_time is the same as AgmaProfile rehearsal_end" do
  		@cclass.start_time = "4PM"
  		@cclass.end_time = "5PM"
  		should be_valid
  	end
  	
  	it "when duration is a multiple of AgmaProfile rehearsal_increment_min" do
  		@cclass.start_time = "4PM"
  		@cclass.end_time = "4:30 PM"
  		should be_valid
  	end
  end
  
  context "(Invalid)" do  	
  	it "when duration is NOT multiple of AgmaProfile rehearsal_increment_min" do
  		@cclass.start_time = "4PM"
  		@cclass.end_time = "4:15 PM"
  		should_not be_valid
  	end
  	
  	it "when start_time is before AgmaProfile rehearsal_start" do
  		@cclass.start_time = "8 AM"
  		@cclass.end_time = "10 AM"
  		should_not be_valid
  	end
  	
  	it "when end_time is after AgmaProfile rehearsal_end" do
  		@cclass.start_time = "4 PM"
  		@cclass.end_time = "6 PM"
  		should_not be_valid
  	end
  end
  
  context "correct value is returned for" do  
	  it "type" do
	  	cclass.reload.type.should == 'CompanyClass'
	  end
	end
end