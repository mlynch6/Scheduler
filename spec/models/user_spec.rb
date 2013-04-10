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
	let(:account) { FactoryGirl.create(:account) }
	let(:employee) { FactoryGirl.create(:employee, account: account) }
	let(:user) { FactoryGirl.create(:user,
				employee: employee,
				username: 'TestUser') }
  before do
  	Account.current_id = employee.account_id
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
  	
  	it { should respond_to(:new_registration) }
  	it { should respond_to(:authenticate) }
  	it { should respond_to(:set_admin_role) }
    
    it "employee_id cannot be changed" do
			new_employee = FactoryGirl.create(:employee)
			user.update_attribute(:employee_id, new_employee.id)
			user.reload.employee_id.should == employee.id
		end
    
    it "should not allow access to role" do
      expect do
        User.new(role: 'Role')
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
	
  context "(Valid)" do
  	describe "when registering a new account & employee_id is blank" do
  		before do
  			@user.new_registration = true
  			@user.employee_id = " "
  		end
  		
  		it { should be_valid }
  	end
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
  	describe "when employee_id is blank" do
  		before {@user.employee_id = " " }
  		it { should_not be_valid }
  	end
  	
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
	  
	  it "superadmin?" do
	  	@user.superadmin?.should be_false
	  	
	  	@user.role = "Super Administrator"
	  	@user.superadmin?.should be_true
	  end
	end
	
	describe "(Methods)" do
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
	
	describe "(Scopes)" do
		before do
			account.employees.delete_all
		end
		let!(:employee1) { FactoryGirl.create(:employee, account: account) }
		let!(:user1) { FactoryGirl.create(:user, employee: employee1) }
		let!(:employee2) { FactoryGirl.create(:employee, account: account) }
		let!(:user2) { FactoryGirl.create(:user, employee: employee2) }
		let!(:employee_wrong_acnt) { FactoryGirl.create(:employee) }
		let!(:user_wrong_acnt) { FactoryGirl.create(:user, employee: employee_wrong_acnt) }
		
		describe "default_scope" do
			it "returns the records for current account" do
				User.all.should == [user1, user2]
			end
		end
	end
end
