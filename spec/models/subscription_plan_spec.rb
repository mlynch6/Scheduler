# == Schema Information
#
# Table name: subscription_plans
#
#  id         :integer          not null, primary key
#  name       :string(50)       not null
#  amount     :decimal(7, 2)    not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe SubscriptionPlan do
  let(:subscription) { FactoryGirl.create(:subscription_plan,
										name: "Basic Subscription",
										amount: 15.25) }
	
	before do
		@subscription = FactoryGirl.build(:subscription_plan)
	end
	
	subject { @subscription }

	context "accessible attributes" do
		it { should respond_to(:name) }
  	it { should respond_to(:amount) }
  	
  	it { should respond_to(:accounts) }
  end
	
  context "(Valid)" do
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "with amount = 0" do
	  	@subscription.amount = 0
	  	should be_valid
	  end
  end

	context "(Invalid)" do
		it "name is blank" do
			@subscription.name = " "
			should_not be_valid
		end
			
		it "when name is too long" do
  		@subscription.name = "a"*51
  		should_not be_valid
  	end
  	
  	context "when amount" do
			it "is blank" do
	  		@subscription.amount = " "
	  		should_not be_valid
	  	end
	  	
	  	it "not a number" do
	  		@subscription.amount = "abc"
	  		should_not be_valid
	  	end
	  	
			it "< 0" do
	  		@subscription.amount = -1
	  		should_not be_valid
	  	end
	  	
	  	it "> 99999.99 (max amount)" do
	  		@subscription.amount = 1000000
	  		should_not be_valid
	  	end
	  end
	end
	
  context "(Associations)" do
		describe "accounts" do
			before { Account.delete_all }
			
			let!(:account1) { FactoryGirl.create(:account, current_subscription_plan: subscription) }
			let!(:account2) { FactoryGirl.create(:account, current_subscription_plan: subscription) }
	
			it "has multiple accounts" do
				subscription.accounts.count.should == 2
			end
		end
  end
  
	context "correct value is returned for" do
		it "name" do
	  	subscription.reload.name.should == "Basic Subscription"
	  end
	  
	  it "amount" do
	  	subscription.reload.amount.should == 15.25
	  end
  end
end
