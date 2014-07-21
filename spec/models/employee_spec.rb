# == Schema Information
#
# Table name: employees
#
#  id                    :integer          not null, primary key
#  account_id            :integer          not null
#  role                  :string(50)       not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  employee_num          :string(20)
#  employment_start_date :date
#  employment_end_date   :date
#  biography             :text
#

require 'spec_helper'

describe Employee do
	let(:account) { FactoryGirl.create(:account) }
	let!(:employee) { FactoryGirl.create(:employee,
										account: account,
										role: 'Artistic Director',
										employee_num: '123',
										employment_start_date: Date.new(2010,8,1),
										employment_end_date: Date.new(2012,5,31),
										biography: 'My bio') }
	let!(:person) { FactoryGirl.create(:person, account: account, profile: employee) }
	
	before do
		Account.current_id = account.id
		@employee = FactoryGirl.build(:employee)
	end
	
	subject { @employee }
	
	context "accessible attributes" do
  	it { should respond_to(:role) }
		it { should respond_to(:employee_num) }
		it { should respond_to(:employment_start_date) }
		it { should respond_to(:employment_end_date) }
		it { should respond_to(:biography) }
  	
  	it { should respond_to(:account) }
  	
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
  	
  	it "when role is a valid value" do
  		roles = ["Artistic Director", "Ballet Master", "Choreographer", "Instructor", "Guest Instructor", "Musician", "Dancer", "Employee"]
  		roles.each do |valid_role|
  			@employee.role = valid_role
  			should be_valid
  		end
  	end
  end
  
  context "(Invalid)" do
  	describe "when role" do
			it "is blank" do
	  		@employee.role = ""
	  		should_not be_valid
	  	end
  	
	  	it "is too long" do
	  		@employee.role = "a"*51
	  		should_not be_valid
	  	end
  	
	  	it "is an invalid value" do
	  		roles = ["test", "freeform text"]
	  		roles.each do |invalid_role|
	  			@employee.role = invalid_role
	  			should_not be_valid
	  		end
	  	end
		end
		
  	it "when employee_num is too long" do
  		@employee.employee_num = "a"*21
  		should_not be_valid
  	end
		
  	it "when employment_start_date is invalid" do
  		dts = ["abc", "2/31/2012"]
  		dts.each do |invalid_date|
  			@employee.employment_start_date = invalid_date
  			should_not be_valid
  		end
		end
		
  	it "when employment_end_date is invalid" do
  		dts = ["abc", "2/31/2012"]
  		dts.each do |invalid_date|
  			@employee.employment_end_date = invalid_date
  			should_not be_valid
  		end
		end
  end
  
  context "(Associations)" do
  	it "has one account" do
			employee.reload.account.should == account
		end
		
  	it "has one profile" do
			employee.person.should == person
		end
  end
  
  context "correct value is returned for" do		
		it "role" do
	  	employee.role.should == 'Artistic Director'
	  end
		
	  it "employee_num" do
	  	employee.reload.employee_num.should == '123'
	  end
		
	  it "employment_start_date" do
	  	employee.reload.employment_start_date.to_s.should == '08/01/2010'
	  end
		
	  it "employment_end_date" do
	  	employee.reload.employment_end_date.to_s.should == '05/31/2012'
	  end
		
	  it "biography" do
	  	employee.reload.biography.should == 'My bio'
	  end
	  
	  describe "Employee::ROLES" do
	  	it "has AGMA Dancer as a value" do
		  	Employee::ROLES.should include("AGMA Dancer")
		  end
		  
		  it "has Artistic Director as a value" do
		  	Employee::ROLES.should include("Artistic Director")
		  end
		  
		  it "has Ballet Master as a value" do
		  	Employee::ROLES.should include("Ballet Master")
		  end
		  
		  it "has Choreographer as a value" do
		  	Employee::ROLES.should include("Choreographer")
		  end
		  
		  it "has Dancer as a value" do
		  	Employee::ROLES.should include("Dancer")
		  end
		  
		  it "has Employee as a value" do
		  	Employee::ROLES.should include("Employee")
		  end
		  
		  it "has Guest Instructor as a value" do
		  	Employee::ROLES.should include("Guest Instructor")
		  end
		  
		  it "has Instructor as a value" do
		  	Employee::ROLES.should include("Instructor")
		  end
		  
		  it "has Musician as a value" do
		  	Employee::ROLES.should include("Musician")
		  end
	  end
		
		context "delegated" do
		  it "first_name" do
		  	employee.first_name.should == person.first_name
		  end
		
		  it "middle_name" do
		  	employee.middle_name.should == person.middle_name
		  end
		
		  it "last_name" do
		  	employee.last_name.should == person.last_name
		  end
		
		  it "suffix" do
		  	employee.suffix.should == person.suffix
		  end
		
		  it "gender" do
		  	employee.gender.should == person.gender
		  end
		
		  it "birth_date" do
		  	employee.birth_date.should == person.birth_date
		  end
		
		  it "email" do
		  	employee.email.should == person.email
		  end
			
		  it "active" do
		  	employee.active.should == person.active
		  end
			
		  it "name" do
		  	employee.name.should == person.name
		  end

		  it "full_name" do
		  	employee.full_name.should == person.full_name
		  end
			
		  it "status" do
		  	employee.status.should == person.status
		  end
			
		  it "addresses" do
				addresses = FactoryGirl.create(:address, addressable: person)
		  	employee.addresses.should == person.addresses
		  end
			
		  it "phones" do
				phone = FactoryGirl.create(:phone, phoneable: person)
		  	employee.phones.should == person.phones
		  end
		end
	end
	
	describe "(Scopes)" do
		before do
			Person.delete_all
			Employee.delete_all
		end
		
		let!(:person3) { FactoryGirl.create(:person, account: account) }
		let!(:person2) { FactoryGirl.create(:person, account: account) }
		let!(:person1) { FactoryGirl.create(:person, account: account) }
		
		let!(:person_inactive) { FactoryGirl.create(:person, :inactive, account: account) }
		let!(:person_wrong_acnt) { FactoryGirl.create(:person, account: FactoryGirl.create(:account)) }
		
		describe "default_scope" do
			it "returns the records for the account" do
				employees = Employee.all
				employees.count.should == 4
				employees.should include(person1.profile)
				employees.should include(person2.profile)
				employees.should include(person3.profile)
				employees.should include(person_inactive.profile)
			end
		end
		
		describe "active" do
			it "returns records where Person is active" do
				employees = Employee.active
				employees.count.should == 3
				employees.should include(person1.profile)
				employees.should include(person2.profile)
				employees.should include(person3.profile)
			end
		end
		
		describe "inactive" do
			it "returns records where Person is inactive" do
				Employee.inactive.should == [person_inactive.profile]
			end
		end
	end
end
