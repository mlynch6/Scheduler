# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  person_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :integer          not null
#  role       :string(20)
#

require 'spec_helper'

describe Invitation do
  let(:account) { FactoryGirl.create(:account) }
	let(:person) { FactoryGirl.create(:person, account: account) }
	let(:event) { FactoryGirl.create(:event, account: account) }
	let(:invitation) { FactoryGirl.create(:invitation,
				account: account,
				event: event,
				person: person) }
	before do
		Account.current_id = account.id
		@invitation = FactoryGirl.build(:invitation)
	end
	
	subject { @invitation }

	context "accessible attributes" do
		it { should respond_to(:role) }
		
		it { should respond_to(:account) }
  	it { should respond_to(:event) }
  	it { should respond_to(:person) }
		
  	it "should not allow access to account_id" do
      expect do
        Invitation.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			before do
				@new_account = FactoryGirl.create(:account)
				invitation.update_attribute(:account_id, @new_account.id)
			end
			
			it { invitation.reload.account_id.should == account.id }
		end
		
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
		
  	it "when role is valid" do
  		roles = ["Artist", "Musician"]
  		roles.each do |valid_role|
  			@invitation.role = valid_role
  			should be_valid
  		end
		end
  end

	context "(Invalid)" do
		it "when account is blank" do
  		@invitation.account_id = " "
  		should_not be_valid
  	end
		
		it "when event is blank" do
  		@invitation.event_id = " "
  		should_not be_valid
  	end
  	
  	it "when person is blank" do
  		@invitation.person_id = " "
  		should_not be_valid
  	end
		
  	it "when role is invalid" do
  		roles = ["abc", "invalid"]
  		roles.each do |invalid_role|
  			@invitation.role = invalid_role
  			should_not be_valid
  		end
		end
  	
  	it "when person/event uniqueness is violated" do
  		@invitation.event = invitation.event
	  	@invitation.person = invitation.person
	  	should_not be_valid
  	end
	end
	
  context "(Associations)" do
		describe "has one" do
			it "account" do
				invitation.reload.account.should == account
			end
			
			it "event" do
				invitation.reload.event.should == event
			end
		
			it "person" do
				invitation.reload.person.should == person
			end
		end
  end
	
	describe "(Scopes)" do
		before do
			Invitation.unscoped.delete_all
		end
		let!(:invitation1) { FactoryGirl.create(:invitation, account: account) }
		let!(:invitation2) { FactoryGirl.create(:invitation, account: account) }
		let!(:invitation_wrong_acnt) { FactoryGirl.create(:invitation, account: FactoryGirl.create(:account) ) }
		
		describe "default_scope" do
			it "returns the records from account" do
				invitations = Invitation.all
				invitations.count.should == 2
				invitations.should include invitation1
				invitations.should include invitation2
			end
		end
	end
end
