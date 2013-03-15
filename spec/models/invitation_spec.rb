# == Schema Information
#
# Table name: invitations
#
#  id          :integer          not null, primary key
#  event_id    :integer          not null
#  employee_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Invitation do
  let(:account) { FactoryGirl.create(:account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:employee) { FactoryGirl.create(:employee, account: account) }
	let(:event) { FactoryGirl.create(:event, account: account, location: location) }
	let(:invitation) { FactoryGirl.create(:invitation,
											event: event,
											employee: employee) }
	before do
		Account.current_id = account.id
		@invitation = FactoryGirl.build(:invitation)
	end
	
	subject { @invitation }

	context "accessible attributes" do
  	it { should respond_to(:event) }
  	it { should respond_to(:employee) }
		
		it "should not allow access to event_id" do
      expect do
        Invitation.new(event_id: event.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    it "should not allow access to employee_id" do
      expect do
        Invitation.new(employee_id: employee.id)
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
  	
  	it "when employee is blank" do
  		@invitation.employee_id = " "
  		should_not be_valid
  	end
  	
  	it "when employee/event uniqueness is violated" do
  		pending
  	end
	end
	
  context "(Associations)" do
		it "has one event" do
			invitation.reload.event.should == event
		end
		
		it "has one employee" do
			invitation.reload.employee.should == employee
		end
  end

	describe "(Scopes)" do
		before do
			event.invitations.delete_all
		end
		
		describe "default_scope" do	
			it "returns the records in alphabetical order by employee" do
				pending
			end
		end
	end
end
