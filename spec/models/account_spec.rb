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
	let(:account) { FactoryGirl.create(:account,
										:name => 'Milwaukee Ballet',
										:main_phone => '414-543-1000',
										:time_zone => 'Eastern Time (US & Canada)') }
  before do
		@account = FactoryGirl.build(:account)
	end
	
	subject { @account }
	
	context "accessible attributes" do
		it { should respond_to(:name) }
		it { should respond_to(:main_phone) }
  	it { should respond_to(:time_zone) }
  	
  	it { should respond_to(:agma_profile) }
  	it { should respond_to(:employees) }
  	it { should respond_to(:locations) }
  	it { should respond_to(:pieces) }
  	it { should respond_to(:events) }
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
  	it "when name is blank" do
  		@account.name = " "
  		should_not be_valid
  	end
  	
  	it "when name is too long" do
  		@account.name = "a"*101
  		should_not be_valid
  	end
  	
  	it "when main_phone is blank" do
  		@account.main_phone = ""
  		should_not be_valid
  	end
  	
  	it "when main_phone is too long" do
  		@account.main_phone = "a"*14
  		should_not be_valid
  	end
  	
  	it "when main_phone in invalid format" do
  		phones = ["111","1 111.222.3333","1basd"]
  		phones.each do |invalid_phone|
  			@account.main_phone = invalid_phone
  			@account.should_not be_valid
  		end
  	end
  	
  	it "when time_zone is blank" do
  		@account.time_zone = ""
  		should_not be_valid
  	end
  	
  	it "when time_zone is too long" do
  		@account.time_zone = "a"*101
  		should_not be_valid
  	end
  	
  	it "when time_zone is invalid" do
  		@account.time_zone = "invalid"
  		should_not be_valid
  	end
  end
  
  context "(Associations)" do
  	describe "agma_profile" do
  		before { Account.current_id = account.id }
			
			it "has one AGMA profile" do
				account.agma_profile.should_not be_nil
			end
			
			it "deletes associated AGMA profile" do
				p = account.agma_profile
				account.destroy
				AgmaProfile.find_by_id(p.id).should be_nil
			end
		end
  	
  	describe "employees" do
  		before { Account.current_id = account.id }
			let!(:second_employee) { FactoryGirl.create(:employee, account: account, last_name: "Brown") }
			let!(:first_employee) { FactoryGirl.create(:employee, account: account, last_name: "Anderson") }
	
			it "has multiple employees" do
				account.employees.count.should == 2
			end
			
			it "deletes associated employees" do
				employees = account.employees
				account.destroy
				employees.each do |employee|
					Employee.find_by_id(employee.id).should be_nil
				end
			end
		end
		
		describe "locations" do
			before { Account.current_id = account.id }
			let!(:second_location) { FactoryGirl.create(:location, account: account, name: "Studio B") }
			let!(:first_location) { FactoryGirl.create(:location, account: account, name: "Studio A") }
	
			it "has multiple locations" do
				account.locations.count.should == 2
			end
			
			it "deletes associated locations" do
				locations = account.locations
				account.destroy
				locations.each do |location|
					Location.find_by_id(location.id).should be_nil
				end
			end
		end
		
		describe "pieces" do
			before { Account.current_id = account.id }
			let!(:second_piece) { FactoryGirl.create(:piece, account: account, name: "Swan Lake") }
			let!(:first_piece) { FactoryGirl.create(:piece, account: account, name: "Nutcracker") }
	
			it "has multiple pieces" do
				account.pieces.count.should == 2
			end
			
			it "deletes associated pieces" do
				pieces = account.pieces
				account.destroy
				pieces.each do |piece|
					Piece.find_by_id(piece.id).should be_nil
				end
			end
		end
		
		describe "events" do
			before { Account.current_id = account.id }
			let!(:second_event) { FactoryGirl.create(:rehearsal, account: account, start_at: 1.hour.ago) }
			let!(:first_event) { FactoryGirl.create(:rehearsal, account: account, start_at: 1.day.ago) }
	
			it "has multiple events" do
				account.events.count.should == 2
			end
			
			it "deletes associated events" do
				events = account.events
				account.destroy
				events.each do |event|
					Event.find_by_id(event.id).should be_nil
				end
			end
		end
  end
	
	context "correct value is returned for" do
		it "name" do
	  	account.reload.name.should == "Milwaukee Ballet"
	  end
	  
	  it "main_phone" do
	  	account.reload.main_phone.should == '414-543-1000'
	  end
	  
	  it "time_zone" do
	  	account.reload.time_zone.should == 'Eastern Time (US & Canada)'
	  end
	  
	  it "current_id" do
	  	Account.current_id = account.id
	  	Account.current_id.should == account.id
	  end
	end
end

describe Account, "(Scopes)" do
	before { Account.delete_all }
	let!(:second_account) { FactoryGirl.create(:account, name: "Beta Account") }
	let!(:first_account) { FactoryGirl.create(:account, name: "Alpha Account") }
		
	describe "default_scope" do
		it "returns the records in alphabetical order" do
			Account.all.should == [first_account, second_account]
		end
	end
end
