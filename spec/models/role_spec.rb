# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(30)       not null
#  piece_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Role do
	let(:piece) { FactoryGirl.create(:piece) }
	before do
		@role = FactoryGirl.build(:role, piece: piece)
	end
	
	subject { @role }
	
	context "accessible attributes" do
		it { should respond_to(:name) }
  	
		it { should respond_to(:piece) }
  	
		it "should NOT allow access to piece_id" do
			expect do
				Role.new(piece_id: piece.id)
			end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
	end
	
	context "(Valid)" do
		it "should be valid with minimum attributes" do
			should be_valid
		end
	end
  
	context "(Invalid)" do
		describe "should be invalid when name is blank" do
			before {@role.name = " " }
			it { should_not be_valid }
		end
  	
		describe "should be invalid when name is too long" do
			before { @role.name = "a"*31 }
			it { should_not be_valid }
		end
  	
  	describe "should be invalid when piece_id is blank" do
  		before { @role.piece_id = nil }
  		it { should_not be_valid }
  	end
  end
  
  context "correct value is returned for" do
  	let(:role) { FactoryGirl.create(:role
  									piece: piece,
  									name: "My Role") }
  	
  	it ".name" do
			role.reload.name.should == 'My Role'
	  end
	  
	  its(:piece) { should == piece }
  end
end

describe Role, "default_scope" do
	let(:piece) { FactoryGirl.create(:piece) }
	let!(:second_role) { FactoryGirl.create(:role, piece: piece, name: 'B Role') }
	let!(:first_role) { FactoryGirl.create(:role, piece: piece, name: 'A Role') }
	
	it "returns the roles in alphabetical order" do
		piece.roles.should == [first_role, second_role]
	end
end
