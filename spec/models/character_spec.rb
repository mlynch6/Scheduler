# == Schema Information
#
# Table name: characters
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  piece_id   :integer          not null
#  name       :string(30)       not null
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Character do
	let(:account) { FactoryGirl.create(:account) }
	let(:piece) { FactoryGirl.create(:piece,
											account: account,
											name: 'Peter Pan') }
	let(:character) { FactoryGirl.create(:character,
											account: account,
											piece: piece,
											name: 'Peter') }
	before do
		Account.current_id = account.id
		@character = FactoryGirl.build(:character)
	end
	
	subject { @character }

	context "accessible attributes" do
		it { should respond_to(:name) }
		it { should respond_to(:position) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:piece) }
  	it { should respond_to(:appearances) }
		it { should respond_to(:castings) }
  	
  	it "should not allow access to account_id" do
      expect do
        Character.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { character.update_attribute(:account_id, new_account.id) }
			
			it { character.reload.account_id.should == account.id }
		end
		
  	it "should not allow access to piece_id" do
      expect do
        Character.new(piece_id: piece.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "piece_id cannot be changed" do
			let(:new_piece) { FactoryGirl.create(:piece) }
			before { character.update_attribute(:piece_id, new_piece.id) }
			
			it { character.reload.piece_id.should == piece.id }
		end
  end

  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end
  
  context "(Saving)" do
  	let!(:p2) { FactoryGirl.create(:piece, account: account) }
  	let!(:character1) { FactoryGirl.create(:character, account: account, piece: p2) }
  	let!(:character2) { FactoryGirl.create(:character, account: account, piece: p2) }
  		
  	it "1st character for a piece, position should be 1" do
  		character1.position.should == 1
  	end
  	
  	it "character for a piece with existing characters, position should be max + 1" do
  		character2.position.should == 2
  	end
  end
  
  context "(Invalid)" do
  	it "when account_id is blank" do
  		@character.account_id = " "
  		should_not be_valid
  	end
  	
  	it "when piece_id is blank" do
  		@character.piece_id = " "
  		should_not be_valid
  	end
  	
  	it "when name is blank" do
  		@character.name = " "
  		should_not be_valid
  	end
  	
  	it "when name is too long" do
  		@character.name = "a"*31
  		should_not be_valid
  	end
  	
  	context "when position" do	  	
	  	it "not an integer" do
	  		vals = ["abc", 8.6]
	  		vals.each do |invalid_integer|
	  			@character.position = invalid_integer
	  			should_not be_valid
	  		end
	  	end
	  	
			it "< 0" do
	  		@character.position = -1
	  		should_not be_valid
	  	end
	  	
	  	it "= 0" do
	  		@character.position = 0
	  		should_not be_valid
	  	end
	  end
  end

	context "(Associations)" do
		it "has one account" do
			character.reload.account.should == account
		end
		
  	it "has one piece" do
			character.reload.piece.should == piece
		end
		
		describe "appearances" do
			let!(:appearance2) { FactoryGirl.create(:appearance, character: character) }
			let!(:appearance1) { FactoryGirl.create(:appearance, character: character) }
	
			it "has multiple appearances" do
				character.appearances.count.should == 2
			end
			
			it "deletes associated appearances" do
				appearances = character.appearances
				character.destroy
				appearances.each do |appearance|
					Appearance.find_by_id(appearance.id).should be_nil
				end
			end
		end
		
  	describe "castings" do
			let!(:season) { FactoryGirl.create(:season, account: account) }
			let!(:season_piece) { FactoryGirl.create(:season_piece, season: season, piece: piece) }
			let!(:cast1) { FactoryGirl.create(:cast, season_piece: season_piece) }
			let!(:cast2) { FactoryGirl.create(:cast, season_piece: season_piece) }
			let!(:casting1) { FactoryGirl.create(:casting, cast: cast1, character: character) }
			let!(:casting2) { FactoryGirl.create(:casting, cast: cast2, character: character) }
	
			it "has multiple castings" do
				character.castings.count.should == 2
			end
			
			it "deletes associated castings" do
				castings = character.castings
				character.destroy
				castings.each do |casting|
					Casting.find_by_id(casting.id).should be_nil
				end
			end
		end
  end
  
	context "correct value is returned for" do
		it "name" do
	  	character.reload.name.should == 'Peter'
	  end
	  
	  it "position" do
	  	character.reload.position.should == 1
	  end
	end

	describe "(Scopes)" do
		before do
			account.characters.delete_all
		end
		let!(:character2) { FactoryGirl.create(:character, account: account, position: 2) }
		let!(:character1) { FactoryGirl.create(:character, account: account, position: 1) }
		let!(:wrong_acnt) { FactoryGirl.create(:account) }
		let!(:piece_wrong_acnt) { FactoryGirl.create(:piece, account: wrong_acnt) }
		let!(:character_wrong_acnt) { FactoryGirl.create(:character, account: wrong_acnt, piece: piece_wrong_acnt) }
		let!(:character3) { FactoryGirl.create(:character, account: account, position: 1) }
		
		describe "default_scope" do
			it "returns the records in position order" do
				Character.all.should == [character1, character3, character2]
			end
		end
	end
end
