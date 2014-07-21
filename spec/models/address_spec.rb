# == Schema Information
#
# Table name: addresses
#
#  id               :integer          not null, primary key
#  addressable_id   :integer          not null
#  addressable_type :string(255)      not null
#  addr_type        :string(30)       not null
#  addr             :string(50)       not null
#  addr2            :string(50)
#  city             :string(50)       not null
#  state            :string(2)        not null
#  zipcode          :string(5)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe Address do
  let(:account) { FactoryGirl.create(:account) }
	let(:address) { FactoryGirl.create(:address,
										addressable: account,
										addr_type: "Work",
										addr: '100 State Street',
										addr2: 'Suite 100',
										city: 'Boston',
										state: 'MA',
										zipcode: '02116') }
	before do
		Account.current_id = account.id
		@address = FactoryGirl.build(:address)
	end
	
	subject { @address }
	
	context "accessible attributes" do
		it { should respond_to(:addr_type) }
		it { should respond_to(:addr) }
		it { should respond_to(:addr2) }
  	it { should respond_to(:city) }
  	it { should respond_to(:state) }
  	it { should respond_to(:zipcode) }
  	
  	it { should respond_to(:addressable) }
  	
  	it "should not allow access to addressable_id" do
      expect do
        Address.new(addressable_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "addressable_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { address.update_attribute(:addressable_id, new_account.id) }
			
			it { address.reload.addressable_id.should == account.id }
		end
  end
  
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "when addr_type is a valid value" do
  		Address::TYPES.each do |valid_type|
  			@address.addr_type = valid_type
  			should be_valid
  		end
  	end
  	
  	it "when state is a valid value" do
  		Address::STATES.each do |state, valid_abbr|
  			@address.state = valid_abbr
  			should be_valid
  		end
  	end
  end
  
  context "(Invalid)" do
  	it "when addr_type is blank" do
  		@address.addr_type = " "
  		should_not be_valid
  	end
  	
  	it "when addr_type is too long" do
  		@address.addr_type = "a"*31
  		should_not be_valid
  	end
  	
  	it "when addr_type in invalid format" do
  		types = ["Emer", 2]
  		types.each do |invalid_type|
  			@address.addr_type = invalid_type
  			should_not be_valid
  		end
  	end
  	
  	it "when addr is blank" do
  		@address.addr = " "
  		should_not be_valid
  	end
  	
  	it "when addr is too long" do
  		@address.addr = "a"*51
  		should_not be_valid
  	end
  	
  	it "when addr2 is too long" do
  		@address.addr2 = "a"*51
  		should_not be_valid
  	end
  	
  	it "when city is blank" do
  		@address.city = ""
  		should_not be_valid
  	end
  	
  	it "when city is too long" do
  		@address.city = "a"*51
  		should_not be_valid
  	end
  	
  	it "when state is blank" do
  		@address.state = ""
  		should_not be_valid
  	end
  	
  	it "when state is too long" do
  		@address.state = "a"*3
  		should_not be_valid
  	end
  	
  	it "when addr_type in invalid format" do
  		states = ["PR", 2]
  		states.each do |invalid_state|
  			@address.state = invalid_state
  			should_not be_valid
  		end
  	end
  	
  	it "when zipcode is blank" do
  		@address.zipcode = ""
  		should_not be_valid
  	end
  	
  	it "when zipcode is too long" do
  		@address.zipcode = "a"*6
  		should_not be_valid
  	end
  end

  context "correct value is returned for" do		
		it "addr_type" do
	  	address.reload.addr_type.should == "Work"
	  end
	  
	  it "addr" do
	  	address.reload.addr.should == "100 State Street"
	  end
	  
	  it "addr2" do
	  	address.reload.addr2.should == 'Suite 100'
	  end
	  
	  it "city" do
	  	address.reload.city.should == 'Boston'
	  end
	  
	  it "state" do
	  	address.reload.state.should == 'MA'
	  end
	  
	  it "zipcode" do
	  	address.reload.zipcode.should == '02116'
	  end
	  
	  describe "Address::TYPES" do
	  	it "has Home as a value" do
		  	Address::TYPES.should include("Home")
		  end
		  
		  it "has Work as a value" do
		  	Address::TYPES.should include("Work")
		  end
	  end
	end
end
