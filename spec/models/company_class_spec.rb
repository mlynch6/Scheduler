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

describe CompanyClass do
	let(:account) { FactoryGirl.create(:account) }
	let(:contract) { account.agma_profile }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:cclass) { FactoryGirl.create(:company_class,
											account: account,
											location: location,
											title: 'Class',
											start_date: Date.new(2012,1,1),
											start_time: "9AM",
											duration: 60) }
	before do
		Account.current_id = account.id
		@cclass = FactoryGirl.build(:company_class)
	end
	
	subject { @cclass }
	
	context "accessible attributes" do
  	it { should respond_to(:break_time) }
  	it { should respond_to(:break_duration) }
  end
	
  context "(Valid)" do
  	it "with minimum attributes" do
  		should be_valid
  		cclass.warnings.count.should == 0
  	end
  	
  	it "without a title - title will be defaulted to 'Company Class'" do
  		cclass.title = ""
  		cclass.save
  		cclass.reload.title.should == "Company Class"
  	end
  	
  	it "when start_time is the same as AgmaProfile rehearsal_start" do
  		@cclass.start_time = contract.rehearsal_start_time
  		@cclass.duration = contract.rehearsal_increment_min
  		should be_valid
  	end
  	
  	it "when end_time is the same as AgmaProfile rehearsal_end" do
  		@cclass.start_time = min_to_formatted_time(contract.rehearsal_end_min - contract.rehearsal_increment_min)
  		@cclass.duration = contract.rehearsal_increment_min
  		should be_valid
  	end
  	
  	it "when duration is a multiple of AgmaProfile rehearsal_increment_min" do
  		@cclass.start_time = contract.rehearsal_start_time
  		@cclass.duration = contract.rehearsal_increment_min
  		should be_valid
  	end
  end
  
  context "(Invalid)" do  	
  	it "when duration is NOT multiple of AgmaProfile rehearsal_increment_min" do
  		@cclass.start_time = contract.rehearsal_start_time
  		@cclass.duration = contract.rehearsal_increment_min - 5
  		should_not be_valid
  	end
  	
  	it "when start_time is before AgmaProfile rehearsal_start" do
  		@cclass.start_time = min_to_formatted_time(contract.rehearsal_start_min - 5)
  		@cclass.duration = contract.rehearsal_increment_min
  		should_not be_valid
  	end
  	
  	it "when end_time is after AgmaProfile rehearsal_end" do
  		@cclass.start_time = min_to_formatted_time(contract.rehearsal_end_min + 5)
  		@cclass.duration = contract.rehearsal_increment_min
  		should_not be_valid
  	end
  end
  
  context "correct value is returned for" do  
	  it "type" do
	  	cclass.reload.type.should == 'CompanyClass'
	  end
	  
	  it "break?" do
			cclass.break?.should be_true
	  end
	end
	
	context "(Methods)" do
		it "break_time" do
			cclass.break_time.should == "10:00 AM to 10:15 AM"
		end
		
		it "break_duration" do
			cclass.break_duration.should == contract.class_break_min
		end
	end
end
