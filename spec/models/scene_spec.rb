# == Schema Information
#
# Table name: scenes
#
#  id         :integer          not null, primary key
#  name       :string(100)      not null
#  order_num  :integer          not null
#  piece_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Scene do
	let(:piece) { FactoryGirl.create(:piece) }
  before do
		@scene = FactoryGirl.build(:scene, piece: piece)
	end
	
	subject { @scene }
	
	context "accessible attributes" do
		it { should respond_to(:name) }
  	it { should respond_to(:order_num) }
  	
  	it { should respond_to(:piece) }
  	
    it "should NOT allow access to piece_id" do
      expect do
        Scene.new(piece_id: piece.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end
	
  context "(Valid)" do
  	it "with minimum attributes" do
  		should be_valid
  	end
  end
  
  context "(Invalid)" do
  	describe "when name is blank" do
  		before {@scene.name = " " }
  		it { should_not be_valid }
  	end
  	
  	describe "when name is too long" do
  		before { @scene.name = "a"*101 }
  		it { should_not be_valid }
  	end
  	
  	describe "when order_num is blank" do
  		before { @scene.order_num = " " }
  		it { should_not be_valid }
  	end
  	
  	describe "when order_num is < 1" do
  		before { @scene.order_num = 0 }
  		it { should_not be_valid }
  	end
  	
		describe "when order_num is not an integer" do
  		before { @scene.order_num = 1.5 }
  		it { should_not be_valid }
  	end
  	
  	describe "when piece_id is blank" do
  		before { @scene.piece_id = nil }
  		it { should_not be_valid }
  	end
  end
  
  context "correct value is returned for" do
  	let(:piece) { FactoryGirl.create(:piece) }
		let(:scene) { FactoryGirl.create(:scene,
											piece: piece,
											name: "My Scene",
											order_num: 1) }
		it ".name" do
			scene.reload.name.should == 'My Scene'
		end
		
		it ".order_num" do
			scene.reload.order_num.should == 1
		end
		
		its(:piece) { should == piece }
  end
end

describe Scene, "scopes" do
	let(:piece) { FactoryGirl.create(:piece) }
	let!(:second_scene) { FactoryGirl.create(:scene, piece: piece, order_num: 2) }
	let!(:first_scene) { FactoryGirl.create(:scene, piece: piece, order_num: 1) }
	
	describe "default_scope" do
		it "returns the scenes in order_num" do
			piece.scenes.should == [first_scene, second_scene]
		end
	end
end

describe Scene, 'before_save' do
	let(:piece) { FactoryGirl.create(:piece) }
	let!(:first_scene) { FactoryGirl.create(:scene, piece: piece, order_num: 1) }
	let!(:second_scene) { FactoryGirl.create(:scene, piece: piece, order_num: 2) }
	let!(:new_first_scene) { FactoryGirl.create(:scene, piece: piece, order_num: 1) }
	
	context "new scene with same order_num as an existing scene" do
		it "new scene should have the set order_num" do
			new_first_scene.reload.order_num.should == 1
		end
		
		it "existing scene should have the next order_num" do
			first_scene.reload.order_num.should == 2
		end
		
		it "other existing scenes should have the next order_num" do
			second_scene.reload.order_num.should == 3
		end
  end
  
  context "edit scene with no changes to order_num" do
  	before { new_first_scene.update_attribute(:name, 'New Name' ) }
		it "should NOT increment the order_num on the scene" do
			new_first_scene.reload.order_num.should == 1
		end
  end
end