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
		@location = FactoryGirl.build(:location)
	end
	
	subject { @location }
	
	context "accessible attributes" do
		it { should respond_to(:name) }
		it { should respond_to(:active) }
  	
  	it { should respond_to(:account) }
  	#it { should respond_to(:events) }
  	
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
  end
  
	context "correct value is returned for" do
		it "name" do
	  	location.reload.name.should == 'Studio A'
	  end
	  
	  it "active?" do
	  	location.reload.active?.should be_true
	  end
	end

	describe "(Scopes)" do
		before do
			account.locations.delete_all
			Account.current_id = account.id
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
