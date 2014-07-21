# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  person_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Invitation do
  let(:account) { FactoryGirl.create(:account) }
	let(:person) { FactoryGirl.create(:person, account: account) }
	let(:event) { FactoryGirl.create(:event, account: account) }
	let(:invitation) { FactoryGirl.create(:invitation,
											event: event,
											person: person) }
	before do
		Account.current_id = account.id
		@invitation = FactoryGirl.build(:invitation)
	end
	
	subject { @invitation }

	context "accessible attributes" do
  	it { should respond_to(:event) }
  	it { should respond_to(:person) }
		
		it "should not allow access to event_id" do
      expect do
        Invitation.new(event_id: event.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    it "should not allow access to person_id" do
      expect do
        Invitation.new(person_id: person.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end

	context "(Invalid)" do
		it "when event is blank" do
  		@invitation.event_id = " "
  		should_not be_valid
  	end
  	
  	it "when person is blank" do
  		@invitation.person_id = " "
  		should_not be_valid
  	end
  	
  	it "when person/event uniqueness is violated" do
  		@invitation.event = invitation.event
	  	@invitation.person = invitation.person
	  	should_not be_valid
  	end
	end
	
  context "(Associations)" do
		it "has one event" do
			invitation.reload.event.should == event
		end
		
		it "has one person" do
			invitation.reload.person.should == person
		end
  end
end
