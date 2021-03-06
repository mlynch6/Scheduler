# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  name       :string(50)       not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Location do
	let(:account) { FactoryGirl.create(:account) }
	let(:location) { FactoryGirl.create(:location,
											account: account,
											name: 'Studio A') }
	before do
		Account.current_id = account.id
		@location = FactoryGirl.build(:location)
	end
	
	subject { @location }
	
	context "accessible attributes" do
		it { should respond_to(:name) }
		it { should respond_to(:active) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:events) }
		it { should respond_to(:company_classes) }
  	
  	it { should respond_to(:activate) }
  	it { should respond_to(:inactivate) }
  	
  	it "should not allow access to account_id" do
      expect do
        Location.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { location.update_attribute(:account_id, new_account.id) }
			
			it { location.reload.account_id.should == account.id }
		end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "created as active" do
  		location.active.should be_true
  	end
  end
  
  context "(Invalid)" do
  	it "when name is blank" do
  		@location.name = " "
  		should_not be_valid
  	end
  	
  	it "when name is too long" do
  		@location.name = "a"*51
  		should_not be_valid
  	end
  	
  	it "when active is blank" do
  		@location.active = ""
  		should_not be_valid
  	end
  end
  
	context "(Associations)" do
  	it "has one account" do
			location.reload.account.should == account
		end
		
		describe "events" do
			let!(:event1) { FactoryGirl.create(:event, account: account, location: location) }
			let!(:event2) { FactoryGirl.create(:event, account: account, location: location) }
	
			it "has multiple events" do
				location.events.count.should == 2
			end
			
			it "deletes associated events" do
				events = location.events
				location.destroy
				events.each do |event|
					Event.find_by_id(event.id).should be_nil
				end
			end
		end
		
		describe "company_classes" do
			let!(:company_class1) { FactoryGirl.create(:company_class, account: account, location: location) }
			let!(:company_class2) { FactoryGirl.create(:company_class, account: account, location: location) }
	
			it "has multiple company_classes" do
				location.company_classes.count.should == 2
			end
			
			it "deletes associated company_classes" do
				company_classes = location.company_classes
				location.destroy
				company_classes.each do |company_class|
					CompanyClass.find_by_id(company_class.id).should be_nil
				end
			end
		end
  end
  
	context "correct value is returned for" do
		it "name" do
	  	location.reload.name.should == 'Studio A'
	  end
	  
	  it "active?" do
	  	location.reload.active?.should be_true
	  end
		
	  describe "status" do
			it "when active is true" do
		  	location.status.should == "Active"
			end
			
			it "when active is false" do
				location.update_attribute(:active, false)
		  	location.reload.status.should == "Inactive"
			end
	  end
	end
	
	context "(Uniqueness)" do
		describe "name" do
			let(:location_diff_account) { FactoryGirl.create(:location, account: FactoryGirl.create(:account)) }
			
			it "is unique within Account" do
	  		@location = location.dup
	  		should_not be_valid
	  	end
	  	
	  	it "can be duplicated across Accounts" do
	  		@location.name = location_diff_account.name
	  		should be_valid
	  	end
	  end
  end
  
	context "(Methods)" do		
		it "activate" do
			location.activate
	  	location.reload.active?.should be_true
	  end
		
		it "inactivate" do
			location.inactivate
	  	location.reload.active?.should be_false
	  end
	  
	  describe "search" do
	  	before do
	  		4.times { FactoryGirl.create(:location, account: account) }
				4.times { FactoryGirl.create(:location, :inactive, account: account) }
				@rhino = FactoryGirl.create(:location, account: account, name: 'Rhino Theatre')
			end
			
	  	it "returns all records by default" do
	  		query = {}
				Location.search(query).should == Location.all
		  end
		  
		  describe "on status" do
			  it "=active returns active records" do
			  	query = { status: "active" }
					Location.search(query).should == Location.active
			  end
			  
			  it "=inactive returns inactive records" do
			  	query = { status: "inactive" }
					Location.search(query).should == Location.inactive
			  end
			  
			  it "that is invalid returns all records" do
			  	query = { status: "invalid" }
					Location.search(query).should == Location.all
			  end
			end
			
		  describe "on text" do
			  it "returns records with query text in name" do
			  	query = { query: "Rhino" }
					records = Location.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
	  end
	end

	describe "(Scopes)" do
		before do
			Location.unscoped.delete_all
		end
		let!(:second_location) { FactoryGirl.create(:location, account: account, name: "Studio B") }
		let!(:first_location) { FactoryGirl.create(:location, account: account, name: "Studio A") }
		let!(:location_inactive) { FactoryGirl.create(:location, :inactive, account: account, name: "Studio Inactive") }
		let!(:location_wrong_acnt) { FactoryGirl.create(:location, account: FactoryGirl.create(:account) ) }
		let!(:location_wrong_acnt_inactive) { FactoryGirl.create(:location, :inactive, account: FactoryGirl.create(:account)) }
		
		describe "default_scope" do
			it "returns the records in alphabetical order" do
				Location.all.should == [first_location, second_location, location_inactive]
			end
		end
		
		describe "active" do
			it "returns active records" do
				Location.active.should == [first_location, second_location]
			end
		end
		
		describe "inactive" do
			it "returns inactive records" do
				Location.inactive.should == [location_inactive]
			end
		end
	end
end
