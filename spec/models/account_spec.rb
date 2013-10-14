# == Schema Information
#
# Table name: accounts
#
#  id                           :integer          not null, primary key
#  name                         :string(100)      not null
#  time_zone                    :string(100)      not null
#  status                       :string(20)       not null
#  cancelled_at                 :datetime
#  stripe_customer_token        :string(100)
#  current_subscription_plan_id :integer          not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

require 'spec_helper'

describe Account do
	let(:subscription) { FactoryGirl.create(:subscription_plan) }
	let(:account) { FactoryGirl.create(:account,
										:name => 'Milwaukee Ballet',
										:time_zone => 'Eastern Time (US & Canada)',
										:current_subscription_plan => subscription) }
  before do
		@account = FactoryGirl.build(:account)
	end
	
	subject { @account }
	
	context "accessible attributes" do
		it { should respond_to(:name) }
  	it { should respond_to(:time_zone) }
  	it { should respond_to(:status) }
  	it { should respond_to(:cancelled_at) }
  	it { should respond_to(:stripe_card_token) }
  	it { should respond_to(:stripe_customer_token) }
  	
  	it { should respond_to(:agma_profile) }
  	it { should respond_to(:current_subscription_plan) }
  	it { should respond_to(:addresses) }
  	it { should respond_to(:phones) }
  	it { should respond_to(:employees) }
  	it { should respond_to(:users) }
  	it { should respond_to(:locations) }
  	it { should respond_to(:seasons) }
  	it { should respond_to(:pieces) }
  	it { should respond_to(:scenes) }
  	it { should respond_to(:events) }
  	
  	it { should respond_to(:save_with_payment) }
  	it { should respond_to(:list_invoices) }
  	it { should respond_to(:next_invoice_date) }
  	it { should respond_to(:cancel_subscription) }
  	
  	it "should not allow access to status" do
      expect do
        Account.new(status: 'Testing')
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    it "should not allow access to cancelled_at" do
      expect do
        Account.new(cancelled_at: Time.zone.now)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "when status is valid value" do
  		statuses = ["Active", "Canceled"]
  		statuses.each do |valid_status|
  			@account.status = valid_status
  			should be_valid
  		end
  	end
  	
  	it "when cancelled_at is blank" do
  		@account.cancelled_at = " "
  		should be_valid
  	end
  	
  	it "when cancelled_at is valid" do
  		@account.cancelled_at = Time.zone.now
  		should be_valid
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
  	
  	it "when status is blank" do
  		account.status = " "
  		account.save
  		account.should_not be_valid
  	end
  	
  	it "when status is too long" do
  		@account.status = "a"*21
  		should_not be_valid
  	end
  	
  	it "when status is invalid" do
  		statuses = ["abc", "Unpaid"]
  		statuses.each do |invalid_status|
  			@account.status = invalid_status
  			should_not be_valid
  		end
  	end
  	
  	it "when cancelled_at in is invalid" do
  		timestamps = ["abc", "2/31/2012", "13:00:00", "2012-02-31 09:00:00"]
  		timestamps.each do |invalid_timestamp|
  			@account.cancelled_at = invalid_timestamp
  			should_not be_valid
  		end
  	end
  	
  	it "when stripe_customer_token is too long" do
  		@account.stripe_customer_token = "a"*101
  		should_not be_valid
  	end
  	
  	it "when current_subscription_plan_id is blank" do
  		@account.current_subscription_plan_id = ""
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
		
		describe "current_subscription_plan" do
			it "belongs to a Subscription Plan" do
				account.current_subscription_plan.should == subscription
			end
		end
  	
  	describe "addresses" do
			before { Account.current_id = account.id }
			let!(:address1) { FactoryGirl.create(:address, addressable: account) }
			let!(:address2) { FactoryGirl.create(:address, addressable: account) }
	
			it "has multiple addresses" do
				account.addresses.count.should == 2
			end
			
			it "deletes associated addresses" do
				addresses = account.addresses
				account.destroy
				addresses.each do |address|
					Address.find_by_id(address.id).should be_nil
				end
			end
		end
		
		describe "phones" do
			before { Account.current_id = account.id }
			let!(:phone1) { FactoryGirl.create(:phone, phoneable: account) }
			let!(:phone2) { FactoryGirl.create(:phone, phoneable: account) }
	
			it "has multiple phone numbers" do
				account.phones.count.should == 2
			end
			
			it "deletes associated phone numbers" do
				phones = account.phones
				account.destroy
				phones.each do |phone|
					Phone.find_by_id(phone.id).should be_nil
				end
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
		
		describe "users" do
  		before { Account.current_id = account.id }
  		let!(:employee1) { FactoryGirl.create(:employee, account: account) }
			let!(:employee2) { FactoryGirl.create(:employee, account: account) }
			let!(:second_user) { FactoryGirl.create(:user, account: account, employee: employee1) }
			let!(:first_user) { FactoryGirl.create(:user, account: account, employee: employee2) }
	
			it "has multiple users" do
				account.users.count.should == 2
			end
			
			it "deletes associated users" do
				users = account.users
				account.destroy
				users.each do |user|
					User.find_by_id(user.id).should be_nil
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
		
		describe "seasons" do
			before { Account.current_id = account.id }
			let!(:second_season) { FactoryGirl.create(:season, account: account) }
			let!(:first_season) { FactoryGirl.create(:season, account: account) }
	
			it "has multiple seasons" do
				account.seasons.count.should == 2
			end
			
			it "deletes associated seasons" do
				seasons = account.seasons
				account.destroy
				seasons.each do |season|
					Season.find_by_id(season.id).should be_nil
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
		
		describe "scenes" do
			before { Account.current_id = account.id }
			let!(:piece) { FactoryGirl.create(:piece, account: account) }
			let!(:scene1) { FactoryGirl.create(:scene, account: account, piece: piece) }
			let!(:scene2) { FactoryGirl.create(:scene, account: account, piece: piece) }
	
			it "has multiple scenes" do
				account.scenes.count.should == 2
			end
			
			it "deletes associated scenes" do
				scenes = account.scenes
				account.destroy
				scenes.each do |scene|
					Scene.find_by_id(scene.id).should be_nil
				end
			end
		end
		
		describe "characters" do
			before { Account.current_id = account.id }
			let!(:piece) { FactoryGirl.create(:piece, account: account) }
			let!(:character1) { FactoryGirl.create(:character, account: account, piece: piece) }
			let!(:character2) { FactoryGirl.create(:character, account: account, piece: piece) }
	
			it "has multiple characters" do
				account.characters.count.should == 2
			end
			
			it "deletes associated characters" do
				characters = account.characters
				account.destroy
				characters.each do |character|
					Character.find_by_id(character.id).should be_nil
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
	  
	  it "time_zone" do
	  	account.reload.time_zone.should == 'Eastern Time (US & Canada)'
	  end
	  
	  it "current_id" do
	  	Account.current_id = account.id
	  	Account.current_id.should == account.id
	  end
	  
	  it "status" do
	  	account.status = "Canceled"
	  	account.save
	  	account.reload.status.should == 'Canceled'
	  end
	  
	  it "cancelled_at" do
	  	tm = Time.zone.now
	  	account.cancelled_at = tm
	  	account.save
	  	account.cancelled_at.should == tm
	  end
	end
	
	context "(Defaults)" do
		it "defaults the status to 'Active'" do
	  	account.reload.status.should == "Active"
	  end
	end
	
	context "(Methods)" do  	
		describe "save_with_payment" do
			before do
				create_stripe_account(account)
			end
			
			after do
    		destroy_stripe_account(account)
    	end
	  	
	  	it "creates record with stripe_customer_token" do
	  		account.stripe_customer_token.should_not be_nil
	  	end
	  end
	  
	  describe "list_invoices" do
			before do
				create_stripe_account(account)
				@invoices = account.list_invoices
			end
			
			after do
    		destroy_stripe_account(account)
    	end
	
	  	it "returns a list from stripe" do
	  		@invoices.count.should == 1
	  		@invoices.first.paid.should be_true
	  	end
	  	
	  	it "handles an error" do
	  		pending
	  	end
	  end
	  
	  describe "next_invoice_date" do
			before do
				create_stripe_account(account)
			end
			
			after do
    		destroy_stripe_account(account)
    	end
	
	  	it "returns next invoice date" do
	  		#Newly created subscription should invoice after 30 day trial
	  		account.next_invoice_date.should == (Time.zone.today + 30.days)
	  	end
	  	
	  	it "handles an error" do
	  		pending
	  	end
	  end
	  
	  describe "cancel_subscription" do
			before do
				create_stripe_account(account)
				account.cancel_subscription
			end
			
			after do
				destroy_stripe_account(account)
    	end
	
	  	it "sets status to Cancelled" do
	  		account.status.should == "Canceled"
	  	end
	  	
	  	it "sets cancelled_at date/time" do
	  		account.cancelled_at.should_not be_nil
	  	end
	  	
	  	it "handles an error" do
	  		pending
	  	end
	  end
  end

	context "(Scopes)" do
		before { Account.delete_all }
		let!(:second_account) { FactoryGirl.create(:account, name: "Beta Account") }
		let!(:first_account) { FactoryGirl.create(:account, name: "Alpha Account") }
			
		describe "default_scope" do
			it "returns the records in alphabetical order" do
				Account.all.should == [first_account, second_account]
			end
		end
	end
end
