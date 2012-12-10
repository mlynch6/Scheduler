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
  end
  
  context "(Invalid)" do
  	describe "when first_name is blank" do
  		before {@employee.first_name = " " }
  		it { should_not be_valid }
  	end
  	
  	describe "when first_name is too long" do
  		before { @employee.first_name = "a"*31 }
  		it { should_not be_valid }
  	end
  	
  	describe "when last_name is blank" do
  		before {@employee.last_name = " " }
  		it { should_not be_valid }
  	end
  	
  	describe "when last_name is too long" do
  		before { @employee.last_name = "a"*31 }
  		it { should_not be_valid }
  	end
  	
  	describe "when active is blank" do
  		before { @employee.active = "" }
  		it { should_not be_valid }
  	end
  	
  	describe "when job_title is too long" do
  		before { @employee.job_title = "a"*51 }
  		it { should_not be_valid }
  	end
  	
  	describe "when email is too long" do
  		before { @employee.email = "a"*51 }
  		it { should_not be_valid }
  	end
  	
  	it "when email in invalid format" do
  		emails = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
  		emails.each do |invalid_email|
  			@employee.email = invalid_email
  			@employee.should_not be_valid
  		end
  	end
  	
  	describe "when phone is too long" do
  		before { @employee.phone = "a"*14 }
  		it { should_not be_valid }
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
  	let(:user) { FactoryGirl.create(:user,
										account: account,
										employee: employee) }
  	
  	it "account" do
			employee.reload.account.should == account
		end
		
		it "user" do
			employee.reload.user.should == user
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
	end
end

describe Employee, "scopes" do
	before { Employee.delete_all }
	let!(:third_employee) { FactoryGirl.create(:employee, last_name: "Brown", first_name: "Brett") }
	let!(:second_employee) { FactoryGirl.create(:employee, last_name: "Brown", first_name: "Andrew") }
	let!(:first_employee) { FactoryGirl.create(:employee, last_name: "Anderson") }
		
	describe "default_scope" do
		it "returns the records in alphabetical order by last_name then first_name" do
			Employee.all.should == [first_employee, second_employee, third_employee]
		end
	end
end
