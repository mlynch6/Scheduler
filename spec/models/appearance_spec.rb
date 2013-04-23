# == Schema Information
#
# Table name: appearances
#
#  id           :integer          not null, primary key
#  scene_id     :integer          not null
#  character_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'spec_helper'

describe Appearance do
  let(:account) { FactoryGirl.create(:account) }
	let(:piece) { FactoryGirl.create(:piece, account: account) }
	let(:scene) { FactoryGirl.create(:scene, account: account, piece: piece) }
	let(:character) { FactoryGirl.create(:character, account: account, piece: piece) }
	let(:appearance) { FactoryGirl.create(:appearance,
											scene: scene,
											character: character) }
	before do
		Account.current_id = account.id
		@appearance = FactoryGirl.build(:appearance)
	end
	
	subject { @appearance }

	context "accessible attributes" do
  	it { should respond_to(:scene) }
  	it { should respond_to(:character) }
		
		it "should not allow access to scene_id" do
      expect do
        Appearance.new(scene_id: scene.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    it "should not allow access to character_id" do
      expect do
        Appearance.new(character_id: character.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end

	context "(Invalid)" do
		it "when scene_id is blank" do
  		@appearance.scene_id = " "
  		should_not be_valid
  	end
  	
  	it "when character_id is blank" do
  		@appearance.character_id = " "
  		should_not be_valid
  	end
  	
  	it "when scene/character uniqueness is violated" do
  		pending
  	end
	end
	
  context "(Associations)" do
		it "has one scene" do
			appearance.reload.scene.should == scene
		end
		
		it "has one character" do
			appearance.reload.character.should == character
		end
  end
end
