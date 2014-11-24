# == Schema Information
#
# Table name: dropdowns
#
#  id            :integer          not null, primary key
#  dropdown_type :string(30)       not null
#  name          :string(30)       not null
#  comment       :text
#  position      :integer          not null
#  active        :boolean          default(TRUE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe Dropdown do
	before do
		Dropdown.destroy_all
		@dropdown = FactoryGirl.build(:dropdown, :phone_type)
	end
	
	let!(:dropdown) { FactoryGirl.create(:dropdown,
										name: 'Artistic Staff',
										comment: 'Job Description') }
	
	subject { @dropdown }
	
	context "accessible attributes" do
  	it { should respond_to(:dropdown_type) }
		it { should respond_to(:name) }
		it { should respond_to(:comment) }
		it { should respond_to(:position) }
		it { should respond_to(:active) }
		it { should respond_to(:status) }
		
		it { should respond_to(:permissions) }
    
  	it "should not allow access to dropdown_type" do
      expect do
        Dropdown.new(dropdown_type: 'UserRole')
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
  
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "created as active" do
  		dropdown.active.should be_true
  	end
		
  	it "created with position = 1" do
  		dropdown.position.should == 1
  	end
  end
  
  context "(Invalid)" do
  	describe "when dropdown_type" do
			it "is blank" do
	  		@dropdown.dropdown_type = ""
	  		should_not be_valid
	  	end
  	
	  	it "is too long" do
	  		@dropdown.dropdown_type = "a"*31
	  		should_not be_valid
	  	end
  	
	  	it "is an invalid value" do
	  		types = ["test", "freeform text"]
	  		types.each do |invalid_type|
	  			@dropdown.dropdown_type = invalid_type
	  			should_not be_valid
	  		end
	  	end
		end
		
  	describe "when name" do
			it "is blank" do
	  		@dropdown.name = ""
	  		should_not be_valid
	  	end
	
	  	it "is too long" do
	  		@dropdown.name = "a"*31
	  		should_not be_valid
	  	end
		end
		
  	context "when position" do	  	
	  	it "not an integer" do
	  		vals = ["abc", 8.6]
	  		vals.each do |invalid_integer|
	  			@dropdown.position = invalid_integer
	  			should_not be_valid
	  		end
	  	end
	  	
			it "< 0" do
	  		@dropdown.position = -1
	  		should_not be_valid
	  	end
	  	
	  	it "= 0" do
	  		@dropdown.position = 0
	  		should_not be_valid
	  	end
	  end
		
  	it "when active is blank" do
  		@dropdown.active = ""
  		should_not be_valid
  	end
  end
	
	context "(Uniqueness)" do
		describe "dropdown_type/name" do
			it "duplicate dropdown_type/name causes error" do
	  		@dropdown.dropdown_type = dropdown.dropdown_type
				@dropdown.name = dropdown.name
				@dropdown.save
	  		should_not be_valid
	  	end
	  	
	  	it "duplicate name allowed on different type" do
				@dropdown.name = dropdown.name
				@dropdown.save
	  		should be_valid
	  	end
			
	  	it "duplicate type allowed on different name" do
				@dropdown.dropdown_type = dropdown.dropdown_type
				@dropdown.save
	  		should be_valid
	  	end
	  end
  end
  
  context "(Associations)" do
		describe "permissions (for UserRole)" do
			let!(:dropdown) { FactoryGirl.create(:dropdown, :user_role) }
			let!(:account) { FactoryGirl.create(:account) }
			let!(:permission1) { FactoryGirl.create(:permission, account: account, role: dropdown) }
			let!(:permission2) { FactoryGirl.create(:permission, account: account, role: dropdown) }
	
			before { Account.current_id = permission1.account.id }
			
			it "has multiple permissions" do
				dropdown.permissions.count.should == 2
			end
			
			it "deletes associated permissions" do
				permissions = dropdown.permissions
				dropdown.destroy
				permissions.each do |permission|
					Permission.find_by_id(permission.id).should be_nil
				end
			end
		end
  end
  
  context "correct value is returned for" do		
		it "dropdown_type" do
	  	dropdown.dropdown_type.should == 'UserRole'
	  end
		
	  it "name" do
	  	dropdown.reload.name.should == 'Artistic Staff'
	  end
		
	  it "comment" do
	  	dropdown.reload.comment.should == 'Job Description'
	  end
		
	  it "position" do
	  	dropdown.reload.position.should == 1
	  end
		
	  it "active" do
	  	dropdown.reload.active.should be_true
	  end
		
	  describe "status" do
			it "when active is true" do
		  	dropdown.status.should == "Active"
			end
			
			it "when active is false" do
				dropdown.update_attribute(:active, false)
		  	dropdown.reload.status.should == "Inactive"
			end
	  end
	  
	  describe "Dropdown::TYPES" do
	  	it "has PhoneType as a value" do
		  	Dropdown::TYPES.should include("PhoneType")
		  end
			
	  	it "has UserRole as a value" do
		  	Dropdown::TYPES.should include("UserRole")
		  end
	  end
	end
	
  context "(Saving)" do
		before do
			Dropdown.delete_all
		end
		
  	let!(:dropdown1) { FactoryGirl.create(:dropdown) }
  	let!(:dropdown2) { FactoryGirl.create(:dropdown) }
  		
  	it "1st dropdown for a type, position should be 1" do
  		dropdown1.position.should == 1
  	end
  	
  	it "dropdown for a type with existing records, position should be max + 1" do
  		dropdown2.position.should == 2
  	end
  end
	
	context "(Methods)" do			  
	  describe "search" do
	  	before do
	  		4.times { FactoryGirl.create(:dropdown, :phone_type) }
				4.times { FactoryGirl.create(:dropdown, :user_role, :inactive) }
				@super_admin_role = FactoryGirl.create(:dropdown, :phone_type, name: 'Super Admin')
			end
			
	  	it "returns all records by default" do
	  		query = {}
				Dropdown.search(query).should == Dropdown.all
		  end
		  
		  describe "on status" do
			  it "=active returns active records" do
			  	query = { status: "active" }
					Dropdown.search(query).should == Dropdown.active
			  end
			  
			  it "=inactive returns inactive records" do
			  	query = { status: "inactive" }
					Dropdown.search(query).should == Dropdown.inactive
			  end
			  
			  it "that is invalid returns all records" do
			  	query = { status: "invalid" }
					Dropdown.search(query).should == Dropdown.all
			  end
			end
			
		  describe "on type" do
			  it "=UserRole returns records with specified dropdown_type" do
			  	query = { type: "UserRole" }
					Dropdown.search(query).should == Dropdown.of_type('UserRole')
			  end
			end
			
		  describe "on text" do
			  it "returns records with query text in name" do
			  	query = { query: "Admin" }
					records = Dropdown.search(query)
					records.count.should == 1
					records.should include(@super_admin_role)
			  end
			end
	  end
	end
	
	describe "(Scopes)" do
		before do
			Dropdown.delete_all
		end
		let!(:dropdown2) { FactoryGirl.create(:dropdown, :phone_type, position: 2) }
		let!(:dropdown1) { FactoryGirl.create(:dropdown, :user_role, position: 1) }
		let!(:dropdown3) { FactoryGirl.create(:dropdown, position: 3) }
		
		describe "default_scope" do
			it "returns the records in position order" do
				Dropdown.all.should == [dropdown1, dropdown2, dropdown3]
			end
		end
		
		describe "of_type" do
			it "returns records with specified dropdown_type" do
				Dropdown.of_type('PhoneType').should == [dropdown2]
			end
		end
		
		describe "active" do
			let!(:dropdown_inactive) { FactoryGirl.create(:dropdown, :inactive) }
			
			it "returns the active records" do
				Dropdown.active.should == [dropdown1, dropdown2, dropdown3]
			end
		end
		
		describe "inactive" do
			let!(:dropdown_inactive) { FactoryGirl.create(:dropdown, :inactive) }
			
			it "returns the inactive records" do
				Dropdown.inactive.should == [dropdown_inactive]
			end
		end
	end
end
