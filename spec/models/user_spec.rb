# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  employee_id     :integer          not null
#  username        :string(20)       not null
#  password_digest :string(255)      not null
#  role            :string(20)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe User do
	let(:employee) { FactoryGirl.create(:employee) }
	let(:user) { FactoryGirl.create(:user,
				employee: employee,
				username: 'TestUser') }
  before do
		@user = FactoryGirl.build(:user, employee: employee)
	end
	
	subject { @user }
	
	context "accessible attributes" do
		it { should respond_to(:username) }
		it { should respond_to(:password_digest) }
  	it { should respond_to(:password) }
  	it { should respond_to(:password_confirmation) }
  	it { should respond_to(:role) }
  	
  	it { should respond_to(:employee) }
  	
  	it { should respond_to(:authenticate) }
  	it { should respond_to(:set_admin_role) }
    
    it "should not allow access to employee_id" do
      expect do
        User.new(employee_id: employee.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    it "should not allow access to role" do
      expect do
        User.new(role: 'Role')
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
	
  context "(Valid)" do
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	describe "when username is minimum length" do
  		before { @user.username = "a"*6 }
  		it { should be_valid }
  	end
  	
  	it "when username is saved as lowercase" do
			user.reload.username.should == 'testuser'
		end
  	
  	describe "when created with role of Employee" do
  		it { user.reload.role.should == 'Employee' }
		end
  end
  
  context "(Invalid)" do
  	describe "when username is blank" do
  		before {@user.username = " " }
  		it { should_not be_valid }
  	end
  	
  	describe "when username is too long" do
  		before { @user.username = "a"*21 }
  		it { should_not be_valid }
  	end
  	
  	describe "when username is too short" do
  		before { @user.username = "a"*5 }
  		it { should_not be_valid }
  	end
  	
  	describe "when username is not unique" do
  		let(:user2) { FactoryGirl.create(:user, :username => 'myUsername') }
										
  		describe "with exact username match" do
	  		before { @user.username = user2.username }
	  		it { should_not be_valid }
	  	end
	  	
	  	describe "with mixed case username match" do
	  		before { @user.username = user2.username.upcase }
	  		it { should_not be_valid }
	  	end
  	end
  	
  	describe "when password is blank" do
  		before { @user.password = @user.password_confirmation = "" }
  		it { should_not be_valid }
  	end
  	
  	describe "when password_confirmation is nil" do
  		before { @user.password_confirmation = nil }
  		it { should_not be_valid }
  	end
  	
  	describe "when password and confirmation are not the same" do
  		before { @user.password_confirmation = "Mismatch" }
  		it { should_not be_valid }
  	end
  	
  	describe "when role is blank" do
			before { user.role = "" }
			it { user.should_not be_valid }
		end
		
		describe "when role is too long" do
  		before { user.role = "a"*21 }
  		it { user.should_not be_valid }
  	end
  end
  
  context "(Associations)" do
  	it "employee" do
	  	user.reload.employee.should == employee
	  end
  end
	
	context "correct value is returned for" do
		it "username" do
	  	user.reload.username.should == "TestUser".downcase
	  end
	  
	  it "role" do
	  	user.reload.role.should == 'Employee'
	  end
	end
	
	describe "employee_id cannot be changed" do
		let(:new_employee) { FactoryGirl.create(:employee) }
		before { user.update_attribute(:employee_id, new_employee.id) }
		
		it { user.reload.employee_id.should == employee.id }
	end
	
	context ".authenticate" do
		let(:found_user) { User.find_by_username(user.username) }
											
		describe "with valid password" do
			it { user.should == found_user.authenticate(user.password) }
		end
		
		describe "with invalid password" do
			let(:invalid_password_user) { found_user.authenticate("invalid") }
			
			it { should_not == invalid_password_user }
			specify { invalid_password_user.should be_false }
		end
	end
	
	context ".set_admin_role" do
		describe "sets role to Administrator" do
			before { user.set_admin_role }
			it { user.reload.role.should == "Administrator" }
		end
	end
end
