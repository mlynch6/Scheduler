# == Schema Information
#
# Table name: employees
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  first_name :string(30)       not null
#  last_name  :string(30)       not null
#  active     :boolean          default(TRUE), not null
#  job_title  :string(50)
#  email      :string(50)
#  phone      :string(13)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Employee do
	let(:account) { FactoryGirl.create(:account) }
	let(:employee) { FactoryGirl.create(:employee,
										account: account,
										first_name: 'Michael',
										last_name: 'Pink',
										active: false,
										job_title: 'Artistic Director',
										email: 'mpink@example.com',
										phone: '414-555-1000') }
	before do
		Account.current_id = account.id
		@employee = FactoryGirl.build(:employee)
	end
	
	subject { @employee }
	
	context "accessible attributes" do
		it { should respond_to(:first_name) }
		it { should respond_to(:last_name) }
		it { should respond_to(:active) }
  	it { should respond_to(:job_title) }
  	it { should respond_to(:email) }
  	it { should respond_to(:phone) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:user) }
  	it { should respond_to(:invitations) }
  	it { should respond_to(:events) }
  	
  	it "should not allow access to account_id" do
      expect do
        Employee.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { employee.update_attribute(:account_id, new_account.id) }
			
			it { employee.reload.account_id.should == account.id }
		end
  end
  
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "when email in valid format" do
  		emails = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
  		emails.each do |valid_email|
  			@employee.email = valid_email
  			@employee.should be_valid
  		end
  	end
  	
  	it "when phone in valid format" do
  		phones = ["111-222-3333","111.222.3333","111 222 3333","1112223333"]
  		phones.each do |valid_phone|
  			@employee.phone = valid_phone
  			@employee.should be_valid
  		end
  	end
  	
  	it "when registering a new account and email is present" do
			@employee.new_registration = true
			@employee.email = Faker::Internet.free_email
  		should be_valid
  	end
  end
  
  context "(Invalid)" do
  	it "when first_name is blank" do
  		@employee.first_name = " "
  		should_not be_valid
  	end
  	
  	it "when first_name is too long" do
  		@employee.first_name = "a"*31
  		should_not be_valid
  	end
  	
  	it "when last_name is blank" do
  		@employee.last_name = " "
  		should_not be_valid
  	end
  	
  	it "when last_name is too long" do
  		@employee.last_name = "a"*31
  		should_not be_valid
  	end
  	
  	it "when active is blank" do
  		@employee.active = ""
  		should_not be_valid
  	end
  	
  	it "when job_title is too long" do
  		@employee.job_title = "a"*51
  		should_not be_valid
  	end
  	
  	it "when email is too long" do
  		@employee.email = "a"*51
  		should_not be_valid
  	end
  	
  	it "when email in invalid format" do
  		emails = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
  		emails.each do |invalid_email|
  			@employee.email = invalid_email
  			@employee.should_not be_valid
  		end
  	end
  	
  	it "when registering a new account and email is blank" do
			@employee.new_registration = true
			@employee.email = " "
  		should_not be_valid
  	end
  	
  	it "when phone is too long" do
  		@employee.phone = "a"*14
  		should_not be_valid
  	end
  	
  	it "when phone in invalid format" do
  		phones = ["111","1 111.222.3333","1basd"]
  		phones.each do |invalid_phone|
  			@employee.phone = invalid_phone
  			@employee.should_not be_valid
  		end
  	end
  end
  
  context "(Associations)" do
  	let!(:user) { FactoryGirl.create(:user,
										employee: employee) }
		let!(:employee_with_no_user) { FactoryGirl.create(:employee) }
  	
  	it "has one account" do
			employee.reload.account.should == account
		end
		
		describe "user" do
			it "has no user" do
				employee_with_no_user.reload.user.should be_nil
			end
			
			it "has one user" do
				employee.reload.user.should == user
			end
			
			it "deletes associated user" do
				u = employee.user
				employee.destroy
				User.find_by_id(u.id).should be_nil
			end
		end
		
		describe "invitations" do
			let(:event1) { FactoryGirl.create(:event, account: account) }
			let(:event2) { FactoryGirl.create(:event, account: account) }
			let!(:second_invite) { FactoryGirl.create(:invitation, event: event1, employee: employee) }
			let!(:first_invite) { FactoryGirl.create(:invitation, event: event2, employee: employee) }
	
			it "has multiple invitations" do
				employee.invitations.count.should == 2
			end
			
			it "deletes associated invitations" do
				invitations = employee.invitations
				employee.destroy
				invitations.each do |invitation|
					Invitation.find_by_id(invitation.id).should be_nil
				end
			end
		end
		
		describe "events" do
			let(:event1) { FactoryGirl.create(:event, account: account) }
			let(:event2) { FactoryGirl.create(:event, account: account) }
			let!(:second_invite) { FactoryGirl.create(:invitation, event: event1, employee: employee) }
			let!(:first_invite) { FactoryGirl.create(:invitation, event: event2, employee: employee) }
			let!(:non_invite) { FactoryGirl.create(:invitation, event: event1) }
	
			it "has multiple events" do
				employee.events.count.should == 2
			end
		end
  end
  
  context "correct value is returned for" do		
		it "first_name" do
	  	employee.reload.first_name.should == "Michael"
	  end
	  
	  it "last_name" do
	  	employee.reload.last_name.should == "Pink"
	  end
	  
	  it "active?" do
	  	employee.reload.active?.should be_false
	  end
	  
	  it "job_title" do
	  	employee.reload.job_title.should == 'Artistic Director'
	  end
	  
	  it "email" do
	  	employee.reload.email.should == 'mpink@example.com'
	  end
	  
	  it "phone" do
	  	employee.reload.phone.should == '414-555-1000'
	  end
	  
	  it "name" do
	  	employee.reload.name.should == 'Pink, Michael'
	  end
	  
	  it "full_name" do
	  	employee.reload.full_name.should == 'Michael Pink'
	  end
	end
	
	context "(Methods)" do		
		it "activate" do
			employee.activate
	  	employee.reload.active?.should be_true
	  end
		
		it "inactivate" do
			employee.inactivate
	  	employee.reload.active?.should be_false
	  end
	end
	
	describe "(Scopes)" do
		before do
			account.employees.delete_all
		end
		let!(:third_employee) { FactoryGirl.create(:employee, account: account, last_name: "Brown", first_name: "Brett") }
		let!(:user3) { FactoryGirl.create(:user, employee: third_employee) }
		
		let!(:second_employee) { FactoryGirl.create(:employee, account: account, last_name: "Brown", first_name: "Andrew") }
		
		let!(:first_employee) { FactoryGirl.create(:employee, account: account, last_name: "Anderson") }
		let!(:user1) { FactoryGirl.create(:user, employee: first_employee) }
		
		let!(:employee_inactive) { FactoryGirl.create(:employee_inactive, account: account, last_name: "Cambell") }
		let!(:employee_wrong_acnt) { FactoryGirl.create(:employee) }
		let!(:employee_wrong_acnt_inactive) { FactoryGirl.create(:employee_inactive) }
		
		describe "default_scope" do
			it "returns the records for the account in alphabetical order by last_name then first_name" do
				Employee.all.should == [first_employee, second_employee, third_employee, employee_inactive]
			end
		end
		
		describe "active" do
			it "returns active records" do
				Employee.active.should == [first_employee, second_employee, third_employee]
			end
		end
		
		describe "inactive" do
			it "returns inactive records" do
				Employee.inactive.should == [employee_inactive]
			end
		end
		
		describe "without_user" do
			it "returns employee records that do not have an associated user" do
				Employee.without_user.should == [second_employee, employee_inactive]
			end
		end
	end
end
