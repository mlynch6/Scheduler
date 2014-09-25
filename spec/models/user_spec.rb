# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  account_id             :integer          not null
#  person_id              :integer          not null
#  username               :string(20)       not null
#  password_digest        :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  password_reset_token   :string(50)
#  password_reset_sent_at :datetime
#  superadmin             :boolean          default(FALSE), not null
#

require 'spec_helper'

describe User do
	let(:account) { FactoryGirl.create(:account) }
	let(:person) { FactoryGirl.create(:person, :complete_record, account: account) }
	let(:user) { FactoryGirl.create(:user,
				account: account,
				person: person,
				username: 'TestUser') }
	
  before do
  	Account.current_id = account.id
		@user = FactoryGirl.build(:user, person: person)
	end
	
	subject { @user }
	
	context "accessible attributes" do
		it { should respond_to(:username) }
		it { should respond_to(:password_digest) }
  	it { should respond_to(:password) }
  	it { should respond_to(:password_confirmation) }
		it { should respond_to(:password_reset_token) }
		it { should respond_to(:password_reset_sent_at) }
		it { should respond_to(:superadmin) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:person) }
		it { should respond_to(:permissions) }
		it { should respond_to(:roles) }
  	
  	it { should respond_to(:authenticate) }
		it { should respond_to(:send_password_reset_email) }
    
    it "person_id cannot be changed" do
			new_person = FactoryGirl.create(:person, account: account)
			user.update_attribute(:person_id, new_person.id)
			user.reload.person_id.should == person.id
		end
		
		it "should not allow access to account_id" do
      expect do
        User.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { user.update_attribute(:account_id, new_account.id) }
			
			it { user.reload.account_id.should == account.id }
		end
    
    it "should not allow access to superadmin" do
      expect do
        User.new(superadmin: true)
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
  	
  	describe "when created as non-superadmin" do
  		it { user.reload.superadmin.should be_false }
		end
  end
  
  context "(Invalid)" do  	
  	describe "when username" do
			it "is blank" do
	  		@user.username = " "
	  		should_not be_valid
	  	end
  	
	  	it "is too long" do
				@user.username = "a"*21
				should_not be_valid
	  	end
  	
	  	it "too short" do
				@user.username = "a"*5
				should_not be_valid
	  	end
  	
	  	describe "is not unique" do
	  		let(:user2) { FactoryGirl.create(:user, :username => 'myUsername') }
										
	  		it "with exact username match" do
					@user.username = user2.username
					should_not be_valid
		  	end
	  	
		  	it "with mixed case username match" do
					@user.username = user2.username.upcase
					should_not be_valid
		  	end
	  	end
		end
  	
  	describe "when password " do
			it "is blank" do
				@user.password = @user.password_confirmation = ""
				should_not be_valid
	  	end
  	
	  	it "and confirmation are not the same" do
				@user.password_confirmation = "Mismatch"
				should_not be_valid
	  	end
		end
		
		it "when superadmin is blank" do
			@user.superadmin = " "
			should_not be_valid
  	end
  end
  
  context "(Associations)" do
  	it "account" do
	  	user.reload.account.should == account
	  end
  	
  	it "person" do
	  	user.reload.person.should == person
	  end
		
		describe "permissions" do
			let!(:permission1) { FactoryGirl.create(:permission, account: account, user: user) }
			let!(:permission2) { FactoryGirl.create(:permission, account: account, user: user) }
	
			it "has multiple permissions" do
				user.permissions.count.should == 2
			end
			
			it "deletes associated permissions" do
				permissions = user.permissions
				user.destroy
				permissions.each do |permission|
					Permission.find_by_id(permission.id).should be_nil
				end
			end
		end
		
		describe "roles" do
			let!(:permission1) { FactoryGirl.create(:permission, account: account, user: user) }
			let!(:permission2) { FactoryGirl.create(:permission, account: account, user: user) }
	
			it "has multiple roles" do
				user.roles.count.should == 2
			end
		end
  end
	
	context "correct value is returned for" do
		it "username" do
	  	user.reload.username.should == "TestUser".downcase
	  end
	  
	  it "superadmin?" do
	  	@user.superadmin?.should be_false
	  	
	  	@user.superadmin = true
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
		
		describe ".send_password_reset_email" do
			before do
				# Done by a user who is not logged in
				Account.current_id = nil
			end
			
			it "generates a unique password_reset_token each time" do
				last_token = user.password_reset_token
				user.send_password_reset_email
				user.password_reset_token.should_not == last_token
			end
			
			it "saves the time the password reset was sent" do
				Timecop.freeze
				user.send_password_reset_email
				user.reload.password_reset_sent_at.should == Time.zone.now
			end
			
			it "delivers email to the person" do
				user.send_password_reset_email
				last_email.to.should include(person.email)
			end
		end
		
		describe "has_role?" do
			before { Rails.application.load_seed }
			let!(:role) { Dropdown.of_type('UserRole').find_by_name('Manage Employees') }
			let!(:permission) { FactoryGirl.create(:permission, account: account, user: user, role: role) }
			
			it "returns true if user has permission" do
				user.has_role?(:manage_employees).should be_true
			end
			
			it "returns false if user does not have permission" do
				user.has_role?(:administrator).should be_false
			end
		end
	end
	
	describe "(Scopes)" do
		before do
			User.unscoped.delete_all
		end
		let!(:user1) { FactoryGirl.create(:user, account: account, username: "alpha123") }
		let!(:user2) { FactoryGirl.create(:user, account: account, username: "beta1234") }
		let!(:user_wrong_acnt) { FactoryGirl.create(:user, account: FactoryGirl.create(:account)) }
		
		describe "default_scope" do
			it "returns the records for current account is alphabetic order by username" do
				users = User.all
				users.count.should == 2
				users.should == [user1, user2]
			end
		end
	end
end
