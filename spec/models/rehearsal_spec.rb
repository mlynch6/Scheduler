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

describe Rehearsal do
	let(:account) { FactoryGirl.create(:account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:piece) { FactoryGirl.create(:piece, account: account) }
	let(:rehearsal) { FactoryGirl.create(:rehearsal,
											account: account,
											location: location,
											title: 'Test Rehearsal',
											start_date: Date.new(2012,1,1),
											start_time: "9AM",
											end_time: "10AM",
											piece: piece) }
	before do
		Account.current_id = account.id
		@rehearsal = FactoryGirl.build(:rehearsal)
	end
	
	subject { @rehearsal }

	context "accessible attributes" do
  	it { should respond_to(:piece) }
  	
    it "should allow access to piece_id" do
      expect do
        Rehearsal.new(piece_id: piece.id)
      end.not_to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end
  
  context "(Invalid)" do
		it "when piece is blank" do
  		@rehearsal.piece_id = " "
  		should_not be_valid
  	end
  end
	
  context "(Associations)" do
		it "has one piece" do
			rehearsal.reload.piece.should == piece
		end
  end
  
  context "correct value is returned for" do  
	  it "type" do
	  	rehearsal.reload.type.should == 'Rehearsal'
	  end
	end
end
