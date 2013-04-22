# == Schema Information
#
# Table name: scenes
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  piece_id   :integer          not null
#  name       :string(100)      not null
#  position   :integer          not null
#  track      :string(20)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Scene do
	let(:account) { FactoryGirl.create(:account) }
	let(:piece) { FactoryGirl.create(:piece,
											account: account,
											name: 'Peter Pan') }
	let(:scene) { FactoryGirl.create(:scene,
											account: account,
											piece: piece,
											name: 'Overture',
											track: "1+2") }
	before do
		Account.current_id = account.id
		@scene = FactoryGirl.build(:scene)
	end
	
	subject { @scene }

	context "accessible attributes" do
		it { should respond_to(:name) }
		it { should respond_to(:position) }
		it { should respond_to(:track) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:piece) }
  	
  	it "should not allow access to account_id" do
      expect do
        Scene.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { scene.update_attribute(:account_id, new_account.id) }
			
			it { scene.reload.account_id.should == account.id }
		end
		
  	it "should not allow access to piece_id" do
      expect do
        Scene.new(piece_id: piece.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "piece_id cannot be changed" do
			let(:new_piece) { FactoryGirl.create(:piece) }
			before { scene.update_attribute(:piece_id, new_piece.id) }
			
			it { scene.reload.piece_id.should == piece.id }
		end
  end

  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end
  
  context "(Saving)" do
  	let!(:p2) { FactoryGirl.create(:piece, account: account) }
  	let!(:scene1) { FactoryGirl.create(:scene, account: account, piece: p2) }
  	let!(:scene2) { FactoryGirl.create(:scene, account: account, piece: p2) }
  		
  	it "1st scene for a piece, position should be 1" do
  		scene1.position.should == 1
  	end
  	
  	it "scene for a piece with existing scenes, position should be max + 1" do
  		scene2.position.should == 2
  	end
  end
  
  context "(Invalid)" do
  	it "when account_id is blank" do
  		@scene.account_id = " "
  		should_not be_valid
  	end
  	
  	it "when piece_id is blank" do
  		@scene.piece_id = " "
  		should_not be_valid
  	end
  	
  	it "when name is blank" do
  		@scene.name = " "
  		should_not be_valid
  	end
  	
  	it "when name is too long" do
  		@scene.name = "a"*101
  		should_not be_valid
  	end
  	
  	context "when position" do	  	
	  	it "not an integer" do
	  		vals = ["abc", 8.6]
	  		vals.each do |invalid_integer|
	  			@scene.position = invalid_integer
	  			should_not be_valid
	  		end
	  	end
	  	
			it "< 0" do
	  		@scene.position = -1
	  		should_not be_valid
	  	end
	  	
	  	it "= 0" do
	  		@scene.position = 0
	  		should_not be_valid
	  	end
	  end
	  
	  it "when track is too long" do
  		@scene.track = "a"*21
  		should_not be_valid
  	end
  end

	context "(Associations)" do
		it "has one account" do
			scene.reload.account.should == account
		end
		
  	it "has one piece" do
			scene.reload.piece.should == piece
		end
  end
  
	context "correct value is returned for" do
		it "name" do
	  	scene.reload.name.should == 'Overture'
	  end
	  
	  it "position" do
	  	scene.reload.position.should == 1
	  end
	  
	  it "track" do
	  	scene.reload.track.should == "1+2"
	  end
	end

	describe "(Scopes)" do
		before do
			account.scenes.delete_all
		end
		let!(:scene2) { FactoryGirl.create(:scene, account: account, position: 2) }
		let!(:scene1) { FactoryGirl.create(:scene, account: account, position: 1) }
		let!(:wrong_acnt) { FactoryGirl.create(:account) }
		let!(:piece_wrong_acnt) { FactoryGirl.create(:piece, account: wrong_acnt) }
		let!(:scene_wrong_acnt) { FactoryGirl.create(:scene, account: wrong_acnt, piece: piece) }
		let!(:scene3) { FactoryGirl.create(:scene, account: account, position: 1) }
		
		describe "default_scope" do
			it "returns the records in position order" do
				Scene.all.should == [scene1, scene3, scene2]
			end
		end
	end
end
