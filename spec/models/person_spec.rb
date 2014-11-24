# == Schema Information
#
# Table name: people
#
#  id           :integer          not null, primary key
#  account_id   :integer          not null
#  profile_id   :integer          not null
#  profile_type :string(50)       not null
#  first_name   :string(30)       not null
#  middle_name  :string(30)
#  last_name    :string(30)       not null
#  suffix       :string(10)
#  gender       :string(10)
#  birth_date   :date
#  email        :string(50)
#  active       :boolean          default(TRUE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'spec_helper'

describe Person do
	let(:account) { FactoryGirl.create(:account) }
	let(:person) { FactoryGirl.create(:person,
										account: account,
										first_name: 'Michael',
										middle_name: 'James',
										last_name: 'Pink',
										suffix: 'Jr',
										gender: 'Male',
										birth_date: Date.new(1970, 8, 4),
										email: 'mpink@example.com') }
	let(:employee) { person.profile }
	
	before do
		Account.current_id = account.id
		@person = FactoryGirl.build(:person)
	end
	
	subject { @person }
	
	context "accessible attributes" do
		it { should respond_to(:first_name) }
		it { should respond_to(:middle_name) }
		it { should respond_to(:last_name) }
		it { should respond_to(:suffix) }
		it { should respond_to(:gender) }
  	it { should respond_to(:birth_date) }
  	it { should respond_to(:email) }
		it { should respond_to(:active) }
  	
  	it { should respond_to(:account) }
		it { should respond_to(:profile) }
  	it { should respond_to(:addresses) }
  	it { should respond_to(:phones) }
		it { should respond_to(:invitations) }
  	it { should respond_to(:events) }
		it { should respond_to(:castings) }
  	
  	it { should respond_to(:name) }
  	it { should respond_to(:full_name) }
		it { should respond_to(:age) }
		it { should respond_to(:activate) }
		it { should respond_to(:inactivate) }
  	
  	it "should not allow access to account_id" do
      expect do
				Person.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { person.update_attribute(:account_id, new_account.id) }
			
			it { person.reload.account_id.should == account.id }
		end
  end
  
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
		
  	it "when gender is a valid value" do
  		values = %w[Male Female]
  		values.each do |valid_gender|
  			@person.gender = valid_gender
  			should be_valid
  		end
  	end
  	
  	it "when email in valid format" do
  		emails = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
  		emails.each do |valid_email|
  			@person.email = valid_email
  			should be_valid
  		end
  	end
		
  	it "created as active" do
  		person.active.should be_true
  	end
  end
  
  context "(Invalid)" do
  	describe "when first_name" do
			it "is blank" do
	  		@person.first_name = " "
	  		should_not be_valid
	  	end
  	
	  	it "is too long" do
	  		@person.first_name = "a"*31
	  		should_not be_valid
	  	end
		end
  	
  	it "when middle_name is too long" do
  		@person.middle_name = "a"*31
  		should_not be_valid
  	end
		
  	describe "when last_name" do
			it "is blank" do
	  		@person.last_name = " "
	  		should_not be_valid
	  	end
  	
	  	it "is too long" do
	  		@person.last_name = "a"*31
	  		should_not be_valid
	  	end
		end
		
  	it "when suffix is too long" do
  		@person.suffix = "a"*11
  		should_not be_valid
  	end
  	
  	describe "when gender" do
	  	it "is too long" do
	  		@person.gender = "a"*11
	  		should_not be_valid
	  	end
  	
	  	it "is an invalid value" do
	  		values = ["test", "freeform text"]
	  		values.each do |invalid_gender|
	  			@person.gender = invalid_gender
	  			should_not be_valid
	  		end
	  	end
		end
		
  	it "when birth_date is invalid" do
  		dts = ["abc", "2/31/2012"]
  		dts.each do |invalid_date|
  			@person.birth_date = invalid_date
  			should_not be_valid
  		end
		end
  	
		describe "when email" do
	  	it "is too long" do
	  		@person.email = "a"*51
	  		should_not be_valid
	  	end
  	
	  	it "has an invalid format" do
	  		emails = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
	  		emails.each do |invalid_email|
	  			@person.email = invalid_email
	  			should_not be_valid
	  		end
	  	end
		end
		
  	it "when active is blank" do
  		@person.active = ""
  		should_not be_valid
  	end
  end
  
  context "(Associations)" do
  	it "has one account" do
			person.reload.account.should == account
		end
		
		it "has one profile" do
			person.reload.profile.should == employee
		end
		
		describe "has 0 or 1 user:" do
			it "no user" do
				person.reload.user.should be_nil
			end
			
			it "1 user" do
				user = FactoryGirl.create(:user, account: account, person: person)
				person.reload.user.should == user
			end
			
			it "deletes associated user" do
				user = FactoryGirl.create(:user, account: account, person: person)
				person.destroy
				User.find_by_id(user.id).should be_nil
			end
		end
		
		describe "addresses" do
			let!(:address1) { FactoryGirl.create(:address, addressable: person) }
			let!(:address2) { FactoryGirl.create(:address, addressable: person) }
	
			it "has multiple addresses" do
				person.addresses.count.should == 2
			end
			
			it "deletes associated addresses" do
				addresses = person.addresses
				person.destroy
				addresses.each do |address|
					Address.find_by_id(address.id).should be_nil
				end
			end
		end

		describe "phones" do
			let!(:phone1) { FactoryGirl.create(:phone, phoneable: person) }
			let!(:phone2) { FactoryGirl.create(:phone, phoneable: person) }
	
			it "has multiple phones" do
				person.phones.count.should == 2
			end
			
			it "deletes associated phones" do
				phones = person.phones
				person.destroy
				phones.each do |phone|
					Phone.find_by_id(phone.id).should be_nil
				end
			end
		end
		
		describe "invitations" do
			let!(:invite2) { FactoryGirl.create(:invitation, account: account, person: person) }
			let!(:invite1) { FactoryGirl.create(:invitation, account: account, person: person) }
	
			it "has multiple invitations" do
				person.invitations.count.should == 2
			end
			
			it "deletes associated invitations" do
				invitations = person.invitations
				person.destroy
				invitations.each do |invitation|
					Invitation.find_by_id(invitation.id).should be_nil
				end
			end
		end
		
		describe "events" do
			let(:event1) { FactoryGirl.create(:event, account: account) }
			let(:event2) { FactoryGirl.create(:event, account: account) }
			let!(:invite2) { FactoryGirl.create(:invitation, account: account, event: event1, person: person) }
			let!(:invite1) { FactoryGirl.create(:invitation, account: account, event: event2, person: person) }
			let!(:non_invite) { FactoryGirl.create(:invitation, account: account, event: event1) }
	
			it "has multiple events" do
				person.events.count.should == 2
			end
		end
		
  	describe "castings" do
			let!(:season) { FactoryGirl.create(:season, account: account) }
			let!(:piece) { FactoryGirl.create(:piece, account: account) }
			let!(:character) { FactoryGirl.create(:character, account: account, piece: piece) }
			let!(:season_piece) { FactoryGirl.create(:season_piece, account: account, season: season, piece: piece) }
			let!(:cast1) { FactoryGirl.create(:cast, account: account, season_piece: season_piece) }
			let!(:cast2) { FactoryGirl.create(:cast, account: account, season_piece: season_piece) }
			
			before do
				casts = [cast1, cast2]
				casts.each do |cast|
					cast.castings.each do |casting|
						casting.person = person
						casting.save
					end
				end
			end
	
			it "has multiple castings" do
				person.castings.count.should == 2
			end
			
			it "nulls person on associated castings when destroying" do
				castings = person.castings
				person.destroy
				castings.each do |casting|
					Casting.find_by_id(casting.id).person_id.should be_nil
				end
			end
		end
  end
  
  context "correct value is returned for" do		
		it "first_name" do
	  	person.reload.first_name.should == "Michael"
	  end
		
		it "middle_name" do
	  	person.reload.middle_name.should == "James"
	  end
	  
	  it "last_name" do
	  	person.reload.last_name.should == "Pink"
	  end
		
	  it "suffix" do
	  	person.reload.suffix.should == "Jr"
	  end
		
	  it "gender" do
	  	person.reload.gender.should == "Male"
	  end
		
	  it "birth_date" do
	  	person.reload.birth_date.to_s.should == '08/04/1970'
	  end
		
	  it "email" do
	  	person.reload.email.should == 'mpink@example.com'
	  end
	  
	  it "active?" do
	  	person.reload.active?.should be_true
	  end
		
	  describe "status" do
			it "when active is true" do
				person.update_attribute(:active, true)
		  	person.reload.status.should == "Active"
			end
			
			it "when active is false" do
				person.update_attribute(:active, false)
		  	person.reload.status.should == "Inactive"
			end
	  end
	  
	  describe "name" do
			it "with only first & last" do
				person.middle_name = ""
				person.suffix = ""
				person.save
		  	person.reload.name.should == 'Pink, Michael'
		  end
			
			it "with middle" do
				person.suffix = ""
				person.save
		  	person.reload.name.should == 'Pink, Michael James'
		  end
			
			it "with suffix" do
				person.middle_name = ""
				person.save
		  	person.reload.name.should == 'Pink Jr, Michael'
		  end
			
			it "with middle and suffix" do
		  	person.reload.name.should == 'Pink Jr, Michael James'
		  end
		end
	  
	  describe "full_name" do
			it "with only first & last" do
				person.middle_name = ""
				person.suffix = ""
				person.save
		  	person.reload.full_name.should == 'Michael Pink'
		  end
			
			it "with middle" do
				person.suffix = ""
				person.save
		  	person.reload.full_name.should == 'Michael James Pink'
		  end
			
			it "with suffix" do
				person.middle_name = ""
				person.save
		  	person.reload.full_name.should == 'Michael Pink Jr'
		  end
			
			it "with middle and suffix" do
		  	person.reload.full_name.should == 'Michael James Pink Jr'
		  end
	  end
		
		describe "age" do
			it "with birth_date" do
				person.birth_date = 9.years.ago.to_date
		  	person.age.should == 9
			end
			
			it "without birth_date" do
				person.birth_date = nil
		  	person.age.should == nil
			end
	  end
	end
	
	context "(Methods)" do		
		it "activate" do
			person.activate
	  	person.reload.active?.should be_true
	  end
	
		it "inactivate" do
			person.inactivate
	  	person.reload.active?.should be_false
	  end
	end
	
	describe "(Scopes)" do
		let!(:person3) { FactoryGirl.create(:person, account: account, last_name: "Brown", first_name: "Brett") }
		let!(:person2) { FactoryGirl.create(:person, account: account, last_name: "Brown", first_name: "Andrew") }
		let!(:person1) { FactoryGirl.create(:person, account: account, last_name: "Anderson") }
		
		let!(:person_inactive) { FactoryGirl.create(:person, :inactive, account: account, last_name: "Cambell") }
		let!(:person_wrong_acnt) { FactoryGirl.create(:person, account: FactoryGirl.create(:account)) }
		let!(:person_wrong_acnt_inactive) { FactoryGirl.create(:person, :inactive, account: FactoryGirl.create(:account)) }
		
		describe "default_scope" do
			it "returns the records for the account in alphabetical order by last_name then first_name" do
				Person.all.should == [person1, person2, person3, person_inactive]
			end
		end
		
		describe "active" do
			it "returns active records" do
				Person.active.should == [person1, person2, person3]
			end
		end
		
		describe "inactive" do
			it "returns inactive records" do
				Person.inactive.should == [person_inactive]
			end
		end
		
		describe "employees" do
			it "returns records with type='Employee'" do
				people = Person.employees
				people.count.should == 4
				people.should include(person1)
				people.should include(person2)
				people.should include(person3)
				people.should include(person_inactive)
			end
		end
		
		describe "agma_members" do
			it "returns records with type='Employee' & agma_artist = true" do
				dancer = FactoryGirl.create(:person, :agma, account: account)

				people = Person.agma_members
				people.count.should == 1
				people.should == [dancer]
			end
		end
		
		describe "instructors" do
			it "returns records with type='Employee' & instructor = true" do
				teacher = FactoryGirl.create(:person, :instructor, account: account)

				people = Person.instructors
				people.count.should == 1
				people.should == [teacher]
			end
		end
		
		describe "musicians" do
			it "returns records with type='Employee' & musician = true" do
				musician = FactoryGirl.create(:person, :musician, account: account)

				people = Person.musicians
				people.count.should == 1
				people.should == [musician]
			end
		end
	end
end
