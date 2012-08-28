# == Schema Information
#
# Table name: pieces
#
#  id         :integer          not null, primary key
#  name       :string(50)       not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Piece do
	before do
		@piece = FactoryGirl.build(:piece)
	end
	
	subject { @piece }
	
  context "(Valid)" do
  	it { should respond_to(:name) }
  	it { should respond_to(:active) }
  	
  	it "should be valid with minimum attributes" do
  		should be_valid
  	end
  	
  	it "should be created as active" do
  		@piece.save
  		@piece.active.should be_true
  	end
  end
  
  context "(Invalid)" do
  	describe "should be invalid when name is blank" do
  		before {@piece.name = "a"*51 }
  		it { should_not be_valid }
  	end
  	
  	describe "should be invalid when name is too long" do
  		before { @piece.name = "a"*51 }
  		it { should_not be_valid }
  	end
  	
  	describe "should be invalid when active is blank" do
  		before { @piece.active = "" }
  		it { should_not be_valid }
  	end
  end
end

describe Piece, '.name' do
	it "should return correct value" do
		piece = FactoryGirl.create(:piece, :name => 'My Piece')
  	piece.name.should == 'My Piece'
  end
end

describe Piece, '.active' do
	it "should return true for active pieces" do
		piece = FactoryGirl.create(:piece)
  	piece.active.should be_true
  end
  
  it "should return false for inactive pieces" do
		piece = Piece.new(:name => 'My Piece', :active => 0)
		piece.save
  	piece.active.should be_false
  end
end