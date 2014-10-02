# == Schema Information
#
# Table name: pieces
#
#  id            :integer          not null, primary key
#  account_id    :integer          not null
#  name          :string(50)       not null
#  choreographer :string(50)
#  music         :string(50)
#  composer      :string(50)
#  avg_length    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe Piece do
	let(:account) { FactoryGirl.create(:account) }
	let(:piece) { FactoryGirl.create(:piece,
											account: account,
											name: 'Swan Lake',
											choreographer: 'Petipa',
											music: 'Swan Lake - music',
											composer: 'Tchaikovsky',
											avg_length: 360) }
	
	before do
		Account.current_id = account.id
		@piece = FactoryGirl.build(:piece)
	end
	
	subject { @piece }

	context "accessible attributes" do
		it { should respond_to(:name) }
		it { should respond_to(:choreographer) }
		it { should respond_to(:music) }
		it { should respond_to(:composer) }
		it { should respond_to(:avg_length) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:scenes) }
  	it { should respond_to(:characters) }
  	it { should respond_to(:season_pieces) }
  	it { should respond_to(:seasons) }
		it { should respond_to(:rehearsals) }
  	
  	it { should respond_to(:name_w_choreographer) }
  	
  	it "should not allow access to account_id" do
      expect do
        Piece.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { piece.update_attribute(:account_id, new_account.id) }
			
			it { piece.reload.account_id.should == account.id }
		end
  end

  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end
  
  context "(Invalid)" do
  	it "when name is blank" do
  		@piece.name = " "
  		should_not be_valid
  	end
  	
  	it "when name is too long" do
  		@piece.name = "a"*51
  		should_not be_valid
  	end
  	
  	it "when choreographer is too long" do
  		@piece.choreographer = "a"*51
  		should_not be_valid
  	end
  	
  	it "when music is too long" do
  		@piece.music = "a"*51
  		should_not be_valid
  	end
  	
  	it "when composer is too long" do
  		@piece.composer = "a"*51
  		should_not be_valid
  	end
  	
  	context "when avg_length" do
			it "not an integer" do
	  		vals = ["abc", 8.6]
	  		vals.each do |invalid_integer|
	  			@piece.avg_length = invalid_integer
	  			should_not be_valid
	  		end
	  	end
	  	
	  	it "< 0" do
	  		@piece.avg_length = -1
	  		should_not be_valid
	  	end
	  	
	  	it "> 1439 (max min in a day)" do
	  		@piece.avg_length = 1440
	  		should_not be_valid
	  	end
		end
  end

	context "(Associations)" do
  	it "has one account" do
			piece.reload.account.should == account
		end
		
		describe "scenes" do
			before { Account.current_id = account.id }
			let!(:second_scene) { FactoryGirl.create(:scene, account: account, piece: piece) }
			let!(:first_scene) { FactoryGirl.create(:scene, account: account, piece: piece) }
	
			it "has multiple scenes" do
				piece.scenes.count.should == 2
			end
			
			it "deletes associated scenes" do
				scenes = piece.scenes
				piece.destroy
				scenes.each do |scene|
					Scene.find_by_id(scene.id).should be_nil
				end
			end
		end
		
		describe "characters" do
			before { Account.current_id = account.id }
			let!(:second_char) { FactoryGirl.create(:character, account: account, piece: piece) }
			let!(:first_char) { FactoryGirl.create(:character, account: account, piece: piece) }
	
			it "has multiple characters" do
				piece.characters.count.should == 2
			end
			
			it "deletes associated characters" do
				characters = piece.characters
				piece.destroy
				characters.each do |character|
					Character.find_by_id(character.id).should be_nil
				end
			end
		end
		
		describe "season_pieces" do
			let!(:sp1) { FactoryGirl.create(:season_piece, account: account, piece: piece) }
			let!(:sp2) { FactoryGirl.create(:season_piece, account: account, piece: piece) }
	
			it "has multiple season_pieces" do
				piece.season_pieces.count.should == 2
			end
			
			it "deletes associated season_pieces" do
				season_pieces = piece.season_pieces
				piece.destroy
				season_pieces.each do |season_piece|
					SeasonPiece.find_by_id(season_piece.id).should be_nil
				end
			end
		end
		
		describe "seasons" do
			let!(:sp1) { FactoryGirl.create(:season_piece, account: account, piece: piece) }
			let!(:sp2) { FactoryGirl.create(:season_piece, account: account, piece: piece) }
	
			it "has multiple seasons" do
				piece.seasons.count.should == 2
			end
		end
		
		describe "rehearsals" do
  		before { Account.current_id = account.id }
			let!(:rehearsal1) { FactoryGirl.create(:rehearsal, account: account, piece: piece) }
			let!(:rehearsal2) { FactoryGirl.create(:rehearsal, account: account, piece: piece) }

			it "has multiple rehearsals" do
				piece.rehearsals.count.should == 2
			end
		
			it "deletes associated rehearsals" do
				rehearsals = piece.rehearsals
				piece.destroy
				rehearsals.each do |rehearsal|
					Rehearsal.find_by_id(rehearsal.id).should be_nil
				end
			end
		end
  end
  
	context "correct value is returned for" do
		it "name" do
	  	piece.reload.name.should == 'Swan Lake'
	  end
	  
	  it "choreographer" do
	  	piece.reload.choreographer.should == 'Petipa'
	  end
	  
	  it "music" do
	  	piece.reload.music.should == 'Swan Lake - music'
	  end
	  
	  it "composer" do
	  	piece.reload.composer.should == 'Tchaikovsky'
	  end
	  
	  it "avg_length" do
	  	piece.reload.avg_length.should == 360
	  end
	end
	
	context "(Uniqueness)" do
		describe "name/choreographer" do
			let(:piece_diff_account) { FactoryGirl.create(:piece, account: FactoryGirl.create(:account)) }
			
			it "duplicate name (no choreographer) causes error within Account" do
	  		piece.choreographer = nil
				piece.save
	  		@piece = piece.dup
	  		should_not be_valid
	  	end
	  	
	  	it "duplicate name (no choreographer) allowed on different Account" do
	  		@piece.name = piece_diff_account.name
	  		should be_valid
	  	end
	  	
	  	it "duplicate name w/ choreographer causes error within Account" do
	  		@piece = piece.dup
	  		should_not be_valid
	  	end
	  	
	  	it "duplicate name w/ choreographer allowed on different Account" do
	  		piece_diff_account.choreographer = 'Martins'
				piece_diff_account.save
	  		@piece.name = piece_diff_account.name
	  		@piece.choreographer = piece_diff_account.choreographer
	  		should be_valid
	  	end
	  	
	  	it "duplicate name w/ 1 choreographer & 1 blank choreographer allowed within Account" do
	  		@piece.name = piece.name
	  		should be_valid
	  	end
	  end
  end

	describe "(Methods)" do
		describe "name_w_choreographer" do
			it "returns name only when no choreographer" do
				piece.choreographer = ""
				piece.save
		  	piece.reload.name_w_choreographer.should == 'Swan Lake'
		  end
		  
		  it "returns name & choreographer when choreographer present" do
		  	piece.reload.name_w_choreographer.should == 'Swan Lake (Petipa)'
		  end
  	end
	end

	describe "(Scopes)" do
		before do
			account.pieces.delete_all
		end
		let!(:second_piece) { FactoryGirl.create(:piece, account: account, name: "Nutcracker") }
		let!(:first_piece) { FactoryGirl.create(:piece, account: account, name: "Giselle") }
		let!(:piece_wrong_acnt) { FactoryGirl.create(:piece, account: FactoryGirl.create(:account)) }
		
		describe "default_scope" do
			it "returns the records in alphabetical order" do
				Piece.all.should == [first_piece, second_piece]
			end
		end
	end
end
