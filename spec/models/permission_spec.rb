# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  user_id    :integer          not null
#  role_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Permission do
  let(:account) { FactoryGirl.create(:account) }
	let(:user) { FactoryGirl.create(:user, account: account) }
	let(:role) { Dropdown.of_type('UserRole').first }
	let(:permission) { FactoryGirl.create(:permission,
											account: account,
											user: user,
											role: role) }
	before do
		Account.current_id = account.id
		@permission = FactoryGirl.build(:permission)
	end
	
	subject { @permission }

	context "accessible attributes" do
  	it { should respond_to(:account) }
		it { should respond_to(:user) }
  	it { should respond_to(:role) }
		
  	it "should not allow access to account_id" do
      expect do
        Permission.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { permission.update_attribute(:account_id, new_account.id) }
			
			it { permission.reload.account_id.should == account.id }
		end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end

	context "(Invalid)" do
		it "when user is blank" do
  		@permission.user_id = " "
  		should_not be_valid
  	end
  	
  	it "when role is blank" do
  		@permission.role_id = " "
  		should_not be_valid
  	end
  	
  	it "when account/user/role uniqueness is violated" do
			@permission.account = permission.account
  		@permission.user = permission.user
	  	@permission.role = permission.role
	  	should_not be_valid
  	end
	end
	
  context "(Associations)" do
		it "has one account" do
			permission.reload.account.should == account
		end
		
		it "has one user" do
			permission.reload.user.should == user
		end
		
		it "has one role" do
			permission.reload.role.should == role
		end
  end
	
	describe "(Scopes)" do
		before do
			Permission.delete_all
		end
		let!(:permission1) { FactoryGirl.create(:permission, account: account) }
		let!(:permission2) { FactoryGirl.create(:permission, account: account) }
		let!(:permission_wrong_acnt) { FactoryGirl.create(:permission, account: FactoryGirl.create(:account)) }
		
		describe "default_scope" do
			it "returns the records from current account" do
				permissions = Permission.all
				permissions.count.should == 2
				permissions.should include(permission1)
				permissions.should include(permission2)
			end
		end
	end
end
