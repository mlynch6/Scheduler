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
  	
  	it { should respond_to(:events) }
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
		before { @location.save }
		let!(:second_event) { FactoryGirl.create(:event, location: @location, start_at: 1.hour.ago) }
		let!(:first_event) { FactoryGirl.create(:event, location: @location, start_at: 2.hours.ago) }

		it "has the events in chronological order" do
			@location.events.should == [first_event, second_event]
		end
		
		it "deletes associated events" do
			events = @location.events
			@location.destroy
			events.each do |event|
				Event.find_by_id(event.id).should be_nil
			end
		end
	end
	
	context "correct value is returned for" do
		let(:location) { FactoryGirl.create(:location, :name => 'Studio A') }
		let(:location_inactive) { FactoryGirl.create(:location_inactive) }
		
		it ".name" do
	  	location.reload.name.should == 'Studio A'
	  end
	  
	  it ".active? when active" do
	  	location.reload.active?.should be_true
	  end
	  
	  it ".active? when inactive" do
	  	location_inactive.reload.active?.should be_false
	  end
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