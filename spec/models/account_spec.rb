# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  name       :string(100)      not null
#  main_phone :string(13)       not null
#  time_zone  :string(100)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Account do
  before do
		@account = FactoryGirl.build(:account)
	end
	
	subject { @account }
	
	context "accessible attributes" do
		it { should respond_to(:name) }
		it { should respond_to(:main_phone) }
  	it { should respond_to(:time_zone) }
  	
  	it { should respond_to(:users) }
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "when main_phone in valid format" do
  		phones = ["111-222-3333","111.222.3333","111 222 3333","1112223333"]
  		phones.each do |valid_phone|
  			@account.main_phone = valid_phone
  			@account.should be_valid
  		end
  	end
  end
  
  context "(Invalid)" do
  	describe "when name is blank" do
  		before {@account.name = " " }
  		it { should_not be_valid }
  	end
  	
  	describe "when name is too long" do
  		before { @account.name = "a"*101 }
  		it { should_not be_valid }
  	end
  	
  	describe "when main_phone is blank" do
  		before { @account.main_phone = "" }
  		it { should_not be_valid }
  	end
  	
  	describe "when main_phone is too long" do
  		before { @account.main_phone = "a"*14 }
  		it { should_not be_valid }
  	end
  	
  	it "when main_phone in invalid format" do
  		phones = ["111","1 111.222.3333","1basd"]
  		phones.each do |invalid_phone|
  			@account.main_phone = invalid_phone
  			@account.should_not be_valid
  		end
  	end
  	
  	describe "when time_zone is blank" do
  		before { @account.time_zone = "" }
  		it { should_not be_valid }
  	end
  	
  	describe "when time_zone is too long" do
  		before { @account.time_zone = "a"*101 }
  		it { should_not be_valid }
  	end
  	
  	describe "when time_zone is invalid" do
  		before { @account.time_zone = "invalid" }
  		it { should_not be_valid }
  	end
  end
  
  describe "user associations" do
		let(:account) { FactoryGirl.create(:account) }
		let!(:second_user) { FactoryGirl.create(:user, account: account) }
		let!(:first_user) { FactoryGirl.create(:user, account: account) }

		it "has the users in order" do
			account.users.should == [second_user, first_user]
		end
		
		it "deletes associated users" do
			users = account.users
			account.destroy
			users.each do |user|
				User.find_by_id(user.id).should be_nil
			end
		end
	end
	
	context "correct value is returned for" do
		let(:account) { FactoryGirl.create(:account,
										:name => 'Milwaukee Ballet',
										:main_phone => '414-543-1000',
										:time_zone => 'Eastern Time (US & Canada)') }
		
		it ".name" do
	  	account.reload.name.should == "Milwaukee Ballet"
	  end
	  
	  it ".main_phone" do
	  	account.reload.main_phone.should == '414-543-1000'
	  end
	  
	  it ".time_zone" do
	  	account.reload.time_zone.should == 'Eastern Time (US & Canada)'
	  end
	end
end

describe Account, "scopes" do
	before { Account.delete_all }
	let!(:second_account) { FactoryGirl.create(:account, name: "Beta Account") }
	let!(:first_account) { FactoryGirl.create(:account, name: "Alpha Account") }
		
	describe "default_scope" do
		it "returns the records in alphabetical order" do
			Account.all.should == [first_account, second_account]
		end
	end
end
