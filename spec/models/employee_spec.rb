# == Schema Information
#
# Table name: employees
#
#  id                    :integer          not null, primary key
#  account_id            :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  employee_num          :string(20)
#  employment_start_date :date
#  employment_end_date   :date
#  biography             :text
#  job_title             :string(50)
#  agma_artist           :boolean          default(FALSE), not null
#  musician              :boolean          default(FALSE), not null
#  instructor            :boolean          default(FALSE), not null
#

require 'spec_helper'

describe Employee do
	let(:account) { FactoryGirl.create(:account) }
	let!(:employee) { FactoryGirl.create(:employee,
										account: account,
										job_title: 'Artistic Director',
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
		it { should respond_to(:employee_num) }
		it { should respond_to(:employment_start_date) }
		it { should respond_to(:employment_end_date) }
		it { should respond_to(:biography) }
		it { should respond_to(:job_title) }
		it { should respond_to(:agma_artist) }
		it { should respond_to(:musician) }
		it { should respond_to(:instructor) }
  	
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
  	
  	it "when created as non- AGMA artist" do
			employee.reload.agma_artist.should be_false
  	end
  end
  
  context "(Invalid)" do
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
		
  	it "job_title is too long" do
			@employee.job_title = "a"*31
			should_not be_valid
		end
		
  	it "agma_artist is blank" do
			@employee.agma_artist = " "
			should_not be_valid
		end
		
  	it "musician is blank" do
			@employee.musician = " "
			should_not be_valid
		end
		
  	it "instructor is blank" do
			@employee.instructor = " "
			should_not be_valid
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
		
		it "job_title" do
	  	employee.job_title.should == 'Artistic Director'
	  end
		
		it "agma_artist" do
	  	employee.agma_artist.should be_false
			
			employee.agma_artist = true
			employee.save
			
			employee.agma_artist.should be_true
	  end
		
		it "musician" do
	  	employee.musician.should be_false
			
			employee.musician = true
			employee.save
			
			employee.musician.should be_true
	  end
		
		it "instructor" do
	  	employee.instructor.should be_false
			
			employee.instructor = true
			employee.save
			
			employee.instructor.should be_true
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
			
		  it "age" do
		  	employee.age.should == person.age
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
	
	context "(Methods)" do		
	  describe "search" do
	  	before do
	  		4.times { FactoryGirl.create(:person, account: account) }
				4.times { FactoryGirl.create(:person, :inactive, account: account) }
				@rhino = FactoryGirl.create(:person, account: account, first_name: 'Richard', last_name: 'Rhinoceros')
			end
			
	  	it "returns all records by default" do
	  		query = {}
				Employee.search(query).should == Employee.all
		  end
		  
		  describe "on status" do
			  it "=active returns active records" do
			  	query = { status: "active" }
					Employee.search(query).should == Employee.active
			  end
			  
			  it "=inactive returns inactive records" do
			  	query = { status: "inactive" }
					Employee.search(query).should == Employee.inactive
			  end
			  
			  it "that is invalid returns all records" do
			  	query = { status: "invalid" }
					Employee.search(query).should == Employee.all
			  end
			end
			
		  describe "on text" do
			  it "returns records with query text in last_name" do
			  	query = { lname: "Rhino" }
					records = Employee.search(query)
					records.count.should == 1
					records.should include(@rhino.profile)
			  end
				
			  it "returns records with query text in first_name" do
			  	query = { fname: "Rich" }
					records = Employee.search(query)
					records.count.should == 1
					records.should include(@rhino.profile)
			  end
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
