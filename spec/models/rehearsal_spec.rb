# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  account_id  :integer          not null
#  title       :string(30)       not null
#  type        :string(20)       not null
#  location_id :integer          not null
#  start_at    :datetime         not null
#  end_at      :datetime         not null
#  piece_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Event do
	let(:account) { FactoryGirl.create(:account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:piece) { FactoryGirl.create(:piece, account: account) }
	let(:event_start) { 2.hours.ago }
	let(:rehearsal) { FactoryGirl.create(:rehearsal,
											account: account,
											location: location,
											title: 'Test Event',
											start_at: event_start,
											end_at: event_start+1.hour,
											piece: piece) }
	before do
		Account.current_id = account.id
		@rehearsal = FactoryGirl.build(:rehearsal)
	end
	
	subject { @rehearsal }

	context "accessible attributes" do
		it { should respond_to(:title) }
  	it { should respond_to(:type) }
  	it { should respond_to(:start_at) }
  	it { should respond_to(:end_at) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:location) }
  	it { should respond_to(:piece) }
  	
  	it "should not allow access to account_id" do
      expect do
        Rehearsal.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { rehearsal.update_attribute(:account_id, new_account.id) }
			
			it { rehearsal.reload.account_id.should == account.id }
		end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end

	context "(Invalid)" do
		it "when title is blank" do
			@rehearsal.title = " "
			should_not be_valid
		end
  	
		it "when title is too long" do
  		@rehearsal.title = "a"*31
  		should_not be_valid
  	end
  	
		it "when type is blank" do
  		@rehearsal.type = " "
  		should_not be_valid
  	end
  	
		it "when type is too long" do
  		@rehearsal.type = "a"*21
  		should_not be_valid
  	end
  	
		it "when location is blank" do
  		@rehearsal.location_id = " "
  		should_not be_valid
  	end
  	
		it "when start_at is blank" do
  		@rehearsal.start_at = " "
  		should_not be_valid
  	end
  	
		it "when start_at is a bad date" do
  		@rehearsal.start_at = "2012-02-31 07:00:00"
  		should_not be_valid
  	end
  	
		it "when end_at is blank" do
  		@rehearsal.end_at = " "
  		should_not be_valid
  	end
  	
		it "when end_at is a bad date" do
  		@rehearsal.end_at = "2012-02-31 07:00:00"
  		should_not be_valid
  	end
  	
		it "when end_at same as start_at" do
			@rehearsal.start_at = 2.hours.ago
			@rehearsal.end_at = @rehearsal.start_at
	  	should_not be_valid
	  end
	  
		it "when end_at is before start_at" do
			@rehearsal.start_at = 1.hour.ago
			@rehearsal.end_at = 2.hours.ago
	  	should_not be_valid
	  end
	end
	
  context "(Associations)" do
		it "has one account" do
			rehearsal.reload.account.should == account
		end
		
		it "has one location" do
			rehearsal.reload.location.should == location
		end
		
		it "has one piece" do
			rehearsal.reload.piece.should == piece
		end
  end
  
	context "correct value is returned for" do
		it "title" do
	  	rehearsal.reload.title.should == 'Test Event'
	  end
	  
	  it "type" do
	  	rehearsal.reload.type.should == 'Rehearsal'
	  end
	  
	  it "start_at" do
			rehearsal.reload.start_at.to_s(:db).should == event_start.to_s(:db)
	  end
	  
	  it "end_at" do
			rehearsal.reload.end_at.to_s(:db).should == (event_start+1.hour).to_s(:db)
	  end
  end

	describe "(Scopes)" do
		before do
			account.events.delete_all
		end
		let!(:second_rehearsal) { FactoryGirl.create(:rehearsal, account: account, start_at: 4.hours.ago) }
		let!(:first_rehearsal) { FactoryGirl.create(:rehearsal, account: account, start_at: 5.hours.ago) }
		let!(:location_wrong_acnt) { FactoryGirl.create(:rehearsal) }
		
		describe "default_scope" do
			it "returns the records in chronilogical order by start" do
				Rehearsal.all.should == [first_rehearsal, second_rehearsal]
			end
		end
	end
end
