# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  title       :string(30)       not null
#  event_type  :string(20)       not null
#  location_id :integer          not null
#  start_at    :datetime         not null
#  end_at      :datetime         not null
#  piece_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Event do
	let(:location) { FactoryGirl.create(:location) }
  before do
		@event = FactoryGirl.build(:event, location: location)
	end
	
	subject { @event }
	
	context "accessible attributes" do
		it { should respond_to(:title) }
  	it { should respond_to(:event_type) }
  	it { should respond_to(:start_at) }
  	it { should respond_to(:end_at) }
  	
  	it { should respond_to(:location) }
  	it { should respond_to(:piece) }
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end
  
  context "(Invalid)" do
  	describe "when title is blank" do
  		before {@event.title = " " }
  		it { should_not be_valid }
  	end
  	
  	describe "when title is too long" do
  		before { @event.title = "a"*31 }
  		it { should_not be_valid }
  	end
  	
  	describe "when event_type is blank" do
  		before {@event.event_type = " " }
  		it { should_not be_valid }
  	end
  	
  	describe "when event_type is too long" do
  		before { @event.event_type = "a"*21 }
  		it { should_not be_valid }
  	end
  	
  	describe "when location is blank" do
  		before {@event.location_id = " " }
  		it { should_not be_valid }
  	end
  	
  	describe "when start_at is blank" do
  		before {@event.start_at = " " }
  		it { should_not be_valid }
  	end
  	
  	describe "when start_at is a bad date" do
  		before {@event.start_at = "2012-02-31 07:00:00" }
  		it { should_not be_valid }
  	end
  	
  	describe "when end_at is blank" do
  		before {@event.end_at = " " }
  		it { should_not be_valid }
  	end
  	
  	describe "when end_at is a bad date" do
  		before {@event.end_at = "2012-02-31 07:00:00" }
  		it { should_not be_valid }
  	end
  	
  	describe "when end_at same as start_at" do
			before do
				@event.start_at = 2.hours.ago
				@event.end_at = @event.start_at
			end
	  	it { should_not be_valid }
	  end
	  
	  describe "when end_at is before start_at" do
			before do
				@event.start_at = 1.hour.ago
				@event.end_at = 2.hours.ago
			end
	  	it { should_not be_valid }
	  end
  end
	
	context "correct value is returned for" do
		let(:piece) { FactoryGirl.create(:piece) }
		let(:event) { FactoryGirl.create(:event, title: "My Event", 
																						event_type: "Performance",
																						location: location,
																						start_at: '2012-10-01 7:00am',
																						end_at: '2012-10-01 8:00am',
																						piece: piece) }
		it ".title" do
	  	event.reload.title.should == 'My Event'
	  end
	  
	  it ".event_type" do
	  	event.reload.event_type.should == 'Performance'
	  end
	  
	  it ".start_at" do
			event.reload.start_at.to_s(:db).should == '2012-10-01 07:00:00'
	  end
	  
	  it ".end_at" do
			event.reload.end_at.to_s(:db).should == '2012-10-01 08:00:00'
	  end
	  
	  it ".piece" do
			event.reload.piece.should == piece
	  end
	  
	  its(:location) { should == location }
	  #its(:piece) { should == piece }
  end
end

describe Event, "scopes" do
	before { Event.delete_all }
	let(:location) { FactoryGirl.create(:location) }
	let!(:second_event) { FactoryGirl.create(:event, location: location, start_at: 1.day.ago) }
	let!(:first_event) { FactoryGirl.create(:event, location: location, start_at: 2.days.ago) }
		
	describe "default_scope" do
		it "returns the records in chronological order" do
			Event.all.should == [first_event, second_event]
		end
	end
end
