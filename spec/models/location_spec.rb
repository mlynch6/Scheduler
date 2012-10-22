# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string(50)       not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Location do
	before do
		@location = FactoryGirl.build(:location)
	end
	
	subject { @location }
	
	context "accessible attributes" do
		it { should respond_to(:name) }
  	it { should respond_to(:active) }
  	
  	#it { should respond_to(:events) }
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "created as active" do
  		@location.save
  		@location.active.should be_true
  	end
  end
  
  context "(Invalid)" do
  	describe "when name is blank" do
  		before {@location.name = " " }
  		it { should_not be_valid }
  	end
  	
  	describe "when name is too long" do
  		before { @location.name = "a"*51 }
  		it { should_not be_valid }
  	end
  	
  	describe "when active is blank" do
  		before { @location.active = "" }
  		it { should_not be_valid }
  	end
  end
  
  describe "event associations" do
		pending
	end
end

describe Location, '.name' do
	let(:location) { FactoryGirl.create(:location, :name => 'Studio A') }
	
	it "returns correct value" do
  	location.reload.name.should == 'Studio A'
  end
end

describe Location, '.active?' do
	let(:location_active) { FactoryGirl.create(:location) }
	let(:location_inactive) { FactoryGirl.create(:location_inactive) }
	
	it "returns true when active" do
  	location_active.reload.active?.should be_true
  end
  
  it "returns false when inactive" do
  	location_inactive.reload.active?.should be_false
  end
end

describe Location, "scopes" do
	before { Location.delete_all }
	let!(:second_location) { FactoryGirl.create(:location, name: "Studio B") }
	let!(:first_location) { FactoryGirl.create(:location, name: "Studio A") }
	let!(:location_inactive) { FactoryGirl.create(:location_inactive, name: "Studio Inactive") }
		
	describe "default_scope" do
		it "returns the records in alphabetical order" do
			Location.all.should == [first_location, second_location, location_inactive]
		end
	end
	
	describe "active" do
		it "returns active records" do
			Location.active.should == [first_location, second_location]
		end
	end
	
	describe "inactive" do
		it "returns inactive records" do
			Location.inactive.should == [location_inactive]
		end
	end
end