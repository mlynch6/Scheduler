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
  	it { should respond_to(:roles) }
  	#it { should respond_to(:performances) }
  	#it { should respond_to(:events) }
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "created as active" do
  		@piece.save
  		@piece.active.should be_true
  	end
  end
  
  context "(Invalid)" do
  	describe "when name is blank" do
  		before {@piece.name = " " }
  		it { should_not be_valid }
  	end
  	
  	describe "when name is too long" do
  		before { @piece.name = "a"*51 }
  		it { should_not be_valid }
  	end
  	
  	describe "when active is blank" do
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
		
		it "deletes associated scenes" do
			scenes = @piece.scenes
			@piece.destroy
			scenes.each do |scene|
				Scene.find_by_id(scene.id).should be_nil
			end
		end
	end
	
	describe "role associations" do
		before { @piece.save }
		let!(:second_role) { FactoryGirl.create(:role, piece: @piece, name: 'Beat Role') }
		let!(:first_role) { FactoryGirl.create(:role, piece: @piece, name: 'Alpha Role') }

		it "has the roles in alphabetical order" do
			@piece.roles.should == [first_role, second_role]
		end
		
		it "deletes associated roles" do
			roles = @piece.roles
			@piece.destroy
			roles.each do |role|
				Role.find_by_id(role.id).should be_nil
			end
		end
	end
	
	describe "performance associations" do
		pending
	end
	
	describe "event associations" do
		pending
	end
end

describe Piece, '.name' do
	let(:piece) { FactoryGirl.create(:piece, :name => 'My Piece') }
	
	it "returns correct value" do
  	piece.reload.name.should == 'My Piece'
  end
end

describe Piece, '.active?' do
	let(:piece_active) { FactoryGirl.create(:piece) }
	let(:piece_inactive) { FactoryGirl.create(:piece_inactive) }
	
	it "returns true when active" do
  	piece_active.reload.active?.should be_true
  end
  
  it "returns false when inactive" do
  	piece_inactive.reload.active?.should be_false
  end
end

describe Piece, "scopes" do
	before { Piece.delete_all }
	let!(:second_piece) { FactoryGirl.create(:piece, name: "Beta") }
	let!(:first_piece) { FactoryGirl.create(:piece, name: "Alpha") }
	let!(:piece_inactive) { FactoryGirl.create(:piece_inactive, name: "Inactive") }
		
	describe "default_scope" do
		it "returns the records in alphabetical order" do
			Piece.all.should == [first_piece, second_piece, piece_inactive]
		end
	end
	
	describe "active" do
		it "returns active records" do
			Piece.active.should == [first_piece, second_piece]
		end
	end
	
	describe "inactive" do
		it "returns inactive records" do
			Piece.inactive.should == [piece_inactive]
		end
	end
end