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
#  gender     :string(10)
#  animal     :boolean          default(FALSE), not null
#  is_child   :boolean          default(FALSE), not null
#  speaking   :boolean          default(FALSE), not null
#  deleted    :boolean          default(FALSE), not null
#  deleted_at :datetime
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
											name: 'Peter',
											gender: 'Male') }
	before do
		Account.current_id = account.id
		@character = FactoryGirl.build(:character)
	end
	
	subject { @character }

	context "accessible attributes" do
		it { should respond_to(:name) }
		it { should respond_to(:position) }
		it { should respond_to(:gender) }
		it { should respond_to(:animal) }
		it { should respond_to(:is_child) }
		it { should respond_to(:speaking) }
		it { should respond_to(:deleted) }
		it { should respond_to(:deleted_at) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:piece) }
  	it { should respond_to(:appearances) }
		it { should respond_to(:castings) }
		
		it { should respond_to(:soft_delete) }
  	
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
		
    it "should not allow access to deleted_at" do
      expect do
        Character.new(deleted_at: Time.zone.now)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  context "(Valid)" do
  	it "with minimum attributes" do
  		should be_valid
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
		
  	it "when gender is invalid" do
  		genders = ["abc", 3, true]
  		genders.each do |invalid_gender|
  			@character.gender = invalid_gender
  			should_not be_valid
  		end
		end
		
  	it "when animal is blank" do
  		@character.animal = ""
  		should_not be_valid
  	end
		
  	it "when is_child is blank" do
  		@character.is_child = ""
  		should_not be_valid
  	end
		
  	it "when speaking is blank" do
  		@character.speaking = ""
  		should_not be_valid
  	end
		
  	it "when deleted is blank" do
  		@character.deleted = ""
  		should_not be_valid
  	end
		
  	it "when deleted_at is invalid" do
  		dts = ["abc", "2/31/2012", "13:00:00"]
  		dts.each do |invalid_datetime|
  			@character.deleted_at = invalid_datetime
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
			let!(:season_piece) { FactoryGirl.create(:season_piece, account: account, season: season, piece: piece) }
			let!(:cast1) { FactoryGirl.create(:cast, account: account, season_piece: season_piece) }
			let!(:cast2) { FactoryGirl.create(:cast, account: account, season_piece: season_piece) }
	
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
		
		it "gender" do
			character.reload.gender.should == "Male"
		end
		
		it "animal?" do
			character.reload.animal?.should be_false
		end
		
		it "is_child?" do
			character.reload.is_child?.should be_false
		end
		
		it "speaking?" do
			character.reload.speaking?.should be_false
		end
		
		it "deleted?" do
			character.reload.deleted?.should be_false
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
		
		describe "active" do
			let!(:character_del) { FactoryGirl.create(:character, account: account, position: 1, deleted: true) }
			
			it "returns the non-deleted records" do
				Character.active.should == [character1, character3, character2]
			end
		end
	end
	
	context "(On Create)" do
		let(:season1) { FactoryGirl.create(:season, account: account) }
		let(:season2) { FactoryGirl.create(:season, account: account) }
		let(:sp1) { FactoryGirl.create(:season_piece, account: account, season: season1, piece: piece) }
		let(:sp2) { FactoryGirl.create(:season_piece_published, account: account, season: season2, piece: piece) }
		let!(:cast1) { FactoryGirl.create(:cast, account: account, season_piece: sp1) }
		let!(:cast2) { FactoryGirl.create(:cast, account: account, season_piece: sp1) }
		let!(:castA) { FactoryGirl.create(:cast, account: account, season_piece: sp2) }
		
  	it "animal is false by default" do
  		character.reload.animal.should be_false
  	end
		
  	it "is_child is false by default" do
  		character.reload.is_child.should be_false
  	end
		
  	it "speaking is false by default" do
  		character.reload.speaking.should be_false
  	end
		
  	it "deleted is false by default" do
  		character.reload.deleted.should be_false
  	end
		
		describe "when character is added to a piece, " do
			it "a casting record is added to non-published casts" do
				new_char = piece.characters.create(name: Faker::Name.name)
				new_char.castings.count.should == 2
				
				cast1.castings.count.should == 1
				cast2.castings.count.should == 1
			end
			
			it "a casting record is NOT added to published casts" do
				new_char = piece.characters.create(name: Faker::Name.name)
				new_char.castings.count.should == 2
				
				castA.castings.count.should == 0
			end
		end
		
		it "deleted_at is set when deleted" do
			Timecop.freeze
			@deleted = FactoryGirl.create(:character_deleted, account: account, piece: piece)
			@deleted.deleted_at.should == Time.zone.now
		end
	end
	
	context "(On Update)" do
		before do
			Timecop.freeze
			@for_update = FactoryGirl.create(:character, account: account, piece: piece)
		end
		
		it "deleted_at is set when deleted" do
			@for_update.update_attribute(:deleted, true)
			
			@for_update.deleted_at.should == Time.zone.now
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
  
	context "(Methods)" do
		describe "soft_delete" do
			let!(:char1) { FactoryGirl.create(:character, account: account, piece: piece) }
			let!(:char2) { FactoryGirl.create(:character, account: account, piece: piece) }
			let(:season) { FactoryGirl.create(:season, account: account) }
			let(:sp) { FactoryGirl.create(:season_piece, account: account, season: season, piece: piece) }
			let!(:cast1) { FactoryGirl.create(:cast, account: account, season_piece: sp) }
			let!(:cast2) { FactoryGirl.create(:cast, account: account, season_piece: sp) }
		
			describe "with no published casts" do
				before { char2.soft_delete }
				
				it "the record is deleted" do
					Character.find_by_id(char2.id).should be_nil
				end
			
				it "associated casting records are removed" do
					Casting.find_by_character_id(char2).should be_nil
					cast1.castings.count.should == 1
					cast2.castings.count.should == 1
				end
			end
		
			describe "with at least 1 published cast" do
				let(:season2) { FactoryGirl.create(:season, account: account) }
				let(:sp_published) { FactoryGirl.create(:season_piece_published, account: account, season: season2, piece: piece) }
				let!(:castA) { FactoryGirl.create(:cast, account: account, season_piece: sp_published) }
				let!(:castB) { FactoryGirl.create(:cast, account: account, season_piece: sp_published) }
				
				before do
					Timecop.freeze
					char2.soft_delete
				end
			
				it "the record is soft-deleted" do
					Character.find_by_id(char2.id).should_not be_nil
					char2.deleted.should be_true
					char2.deleted_at.should == Time.zone.now
				end
			
				it "associated casting records are removed for non-published casts" do
					sp.published.should be_false
					cast1.castings.count.should == 1
					cast2.castings.count.should == 1
				end
			
				it "associated casting records remain for published casts" do
					sp_published.published.should be_true
					castA.castings.count.should == 2
					castB.castings.count.should == 2
				end
			end
		end
	end
end
