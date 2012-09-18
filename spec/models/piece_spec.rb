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
	
	context "accessible attributes" do
		it { should respond_to(:name) }
  	it { should respond_to(:active) }
  	it { should respond_to(:scenes) }    
  end
	
  context "(Valid)" do  	
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
  		before {@piece.name = " " }
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
  
  describe "scene associations" do
		before { @piece.save }
		let!(:second_scene) { FactoryGirl.create(:scene, piece: @piece, order_num: 2) }
		let!(:first_scene) { FactoryGirl.create(:scene, piece: @piece, order_num: 1) }

		it "has the scenes in order" do
			@piece.scenes.should == [first_scene, second_scene]
		end
		
		it "should delete associated scenes" do
			scenes = @piece.scenes
			@piece.destroy
			scenes.each do |scene|
				Scene.find_by_id(scene.id).should be_nil
			end
		end
	end
end

describe Piece, '.name' do
	let(:piece) { FactoryGirl.create(:piece, :name => 'My Piece') }
	
	it "should return correct value" do
  	piece.reload.name.should == 'My Piece'
  end
end

describe Piece, '.active?' do
	let(:piece_active) { FactoryGirl.create(:piece) }
	let(:piece_inactive) { FactoryGirl.create(:piece_inactive) }
	
	it "returns true for active pieces" do
  	piece_active.reload.active.should be_true
  end
  
  it "returns false for inactive pieces" do
  	piece_inactive.reload.active.should be_false
  end
end

describe Piece, "default_scope" do
	before { Piece.delete_all }
	let!(:second_piece) { FactoryGirl.create(:piece, name: "Beta") }
	let!(:first_piece) { FactoryGirl.create(:piece, name: "Alpha") }
	
	it "returns the pieces in order of name" do
		Piece.all.should == [first_piece, second_piece]
	end
end