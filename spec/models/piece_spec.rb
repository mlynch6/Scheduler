# == Schema Information
#
# Table name: pieces
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  name       :string(50)       not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Piece do
	let(:account) { FactoryGirl.create(:account) }
	let(:piece) { FactoryGirl.create(:piece,
											account: account,
											name: 'Swan Lake') }
	before do
		Account.current_id = account.id
		@piece = FactoryGirl.build(:piece)
	end
	
	subject { @piece }

	context "accessible attributes" do
		it { should respond_to(:name) }
		it { should respond_to(:active) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:events) }
  	it { should respond_to(:season_pieces) }
  	it { should respond_to(:seasons) }
  	
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
  	
  	it "created as active" do
  		piece.active.should be_true
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
  	
  	it "when active is blank" do
  		@piece.active = ""
  		should_not be_valid
  	end
  end

	context "(Associations)" do
  	it "has one account" do
			piece.reload.account.should == account
		end
		
		describe "scenes" do
			before { Account.current_id = account.id }
			let!(:second_scene) { FactoryGirl.create(:scene, account: account, piece: piece, position: 2) }
			let!(:first_scene) { FactoryGirl.create(:scene, account: account, piece: piece, position: 1) }
	
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
			let!(:second_char) { FactoryGirl.create(:character, account: account, piece: piece, position: 2) }
			let!(:first_char) { FactoryGirl.create(:character, account: account, piece: piece, position: 1) }
	
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
		
		describe "events" do
			before { Account.current_id = account.id }
			let!(:second_event) { FactoryGirl.create(:rehearsal, account: account, piece: piece) }
			let!(:first_event) { FactoryGirl.create(:rehearsal, account: account, piece: piece) }
	
			it "has multiple events" do
				account.events.count.should == 2
			end
			
			it "deletes associated events" do
				events = piece.events
				piece.destroy
				events.each do |event|
					Event.find_by_id(event.id).should be_nil
				end
			end
		end
		
		describe "season_pieces" do
			let(:season1) { FactoryGirl.create(:season, account: account) }
			let(:season2) { FactoryGirl.create(:season, account: account) }
			let!(:second_inter) { FactoryGirl.create(:season_piece, season: season1, piece: piece) }
			let!(:first_inter) { FactoryGirl.create(:season_piece, season: season2, piece: piece) }
	
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
			let(:season1) { FactoryGirl.create(:season, account: account) }
			let(:season2) { FactoryGirl.create(:season, account: account) }
			let!(:second_inter) { FactoryGirl.create(:season_piece, season: season1, piece: piece) }
			let!(:first_inter) { FactoryGirl.create(:season_piece, season: season2, piece: piece) }
	
			it "has multiple seasons" do
				piece.seasons.count.should == 2
			end
		end
  end
  
	context "correct value is returned for" do
		it "name" do
	  	piece.reload.name.should == 'Swan Lake'
	  end
	  
	  it "active?" do
	  	piece.reload.active?.should be_true
	  end
	end
	
	context "(Uniqueness)" do
		describe "name" do
			let(:piece_diff_account) { FactoryGirl.create(:piece) }
			
			it "is unique within Account" do
	  		@piece = piece.dup
	  		should_not be_valid
	  	end
	  	
	  	it "can be duplicated across Accounts" do
	  		@piece.name = piece_diff_account.name
	  		should be_valid
	  	end
	  end
  end
  
	context "(Methods)" do		
		it "activate" do
			piece.activate
	  	piece.reload.active?.should be_true
	  end
		
		it "inactivate" do
			piece.inactivate
	  	piece.reload.active?.should be_false
	  end
	end

	describe "(Scopes)" do
		before do
			account.pieces.delete_all
		end
		let!(:second_piece) { FactoryGirl.create(:piece, account: account, name: "Nutcracker") }
		let!(:first_piece) { FactoryGirl.create(:piece, account: account, name: "Giselle") }
		let!(:piece_inactive) { FactoryGirl.create(:piece_inactive, account: account, name: "Rodeo") }
		let!(:piece_wrong_acnt) { FactoryGirl.create(:piece) }
		let!(:piece_wrong_acnt_inactive) { FactoryGirl.create(:piece_inactive) }
		
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
end
