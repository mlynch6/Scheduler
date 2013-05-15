# == Schema Information
#
# Table name: phones
#
#  id             :integer          not null, primary key
#  phoneable_id   :integer          not null
#  phoneable_type :string(255)      not null
#  phone_type     :string(20)       not null
#  phone_num      :string(13)       not null
#  primary        :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe Phone do
  let(:account) { FactoryGirl.create(:account) }
	let(:phone) { FactoryGirl.create(:phone,
										phoneable: account,
										phone_type: "Work",
										phone_num: '222-555-2222') }
	before do
		Account.current_id = account.id
		@phone = FactoryGirl.build(:phone)
	end
	
	subject { @phone }
	
	context "accessible attributes" do
		it { should respond_to(:phone_type) }
		it { should respond_to(:phone_num) }
		it { should respond_to(:primary) }
  	
  	it { should respond_to(:phoneable) }
  	
  	it "should not allow access to phoneable_id" do
      expect do
        Phone.new(phoneable_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "phoneable_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { phone.update_attribute(:phoneable_id, new_account.id) }
			
			it { phone.reload.phoneable_id.should == account.id }
		end
  end
  
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "when phone_type is a valid value" do
  		Phone::TYPES.each do |valid_type|
  			@phone.phone_type = valid_type
  			should be_valid
  		end
  	end
  end
  
  context "(Invalid)" do  	
  	it "when phone_type is blank" do
  		@phone.phone_type = " "
  		should_not be_valid
  	end
  	
  	it "when phone_type is too long" do
  		@phone.phone_type = "a"*21
  		should_not be_valid
  	end
  	
  	it "when phone_type in invalid format" do
  		types = ["Emer", 2]
  		types.each do |invalid_type|
  			@phone.phone_type = invalid_type
  			should_not be_valid
  		end
  	end
  	
  	it "when phone_num is blank" do
  		@phone.phone_num = " "
  		should_not be_valid
  	end
  	
  	it "when phone_num is too long" do
  		@phone.phone_num = "a"*14
  		should_not be_valid
  	end
  	
  	it "when primary is blank" do
  		@phone.primary = ""
  		should_not be_valid
  	end
  end

  context "correct value is returned for" do		
		it "phone_type" do
	  	phone.reload.phone_type.should == "Work"
	  end
	  
	  it "phone_num" do
	  	phone.reload.phone_num.should == "222-555-2222"
	  end
	  
	  it "primary" do
	  	phone.reload.primary.should be_false
	  end
	  
	  describe "Phone::TYPES" do
	  	it "has Home as a value" do
		  	Phone::TYPES.should include("Home")
		  end
		  
		  it "has Work as a value" do
		  	Phone::TYPES.should include("Work")
		  end
		  
		  it "has Cell as a value" do
		  	Phone::TYPES.should include("Cell")
		  end
		  
		  it "has Fax as a value" do
		  	Phone::TYPES.should include("Fax")
		  end
		  
		  it "has Emergency as a value" do
		  	Phone::TYPES.should include("Emergency")
		  end
	  end
	end
	
	it "can only have 1 primary"
	it "primary cannot be deleted"
end
