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
			let!(:second_event) { FactoryGirl.create(:rehearsal, account: account, location: location) }
			let!(:first_event) { FactoryGirl.create(:rehearsal, account: account, location: location) }
	
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
  end
  
	context "correct value is returned for" do
		it "name" do
	  	location.reload.name.should == 'Studio A'
	  end
	  
	  it "active?" do
	  	location.reload.active?.should be_true
	  end
	end
	
	context "(Uniqueness)" do
		describe "name" do
			let(:location_diff_account) { FactoryGirl.create(:location) }
			
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
	end

	describe "(Scopes)" do
		before do
			account.locations.delete_all
		end
		let!(:second_location) { FactoryGirl.create(:location, account: account, name: "Studio B") }
		let!(:first_location) { FactoryGirl.create(:location, account: account, name: "Studio A") }
		let!(:location_inactive) { FactoryGirl.create(:location_inactive, account: account, name: "Studio Inactive") }
		let!(:location_wrong_acnt) { FactoryGirl.create(:location) }
		let!(:location_wrong_acnt_inactive) { FactoryGirl.create(:location_inactive) }
		
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
