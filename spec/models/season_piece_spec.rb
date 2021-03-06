# == Schema Information
#
# Table name: season_pieces
#
#  id           :integer          not null, primary key
#  account_id   :integer          not null
#  season_id    :integer          not null
#  piece_id     :integer          not null
#  published    :boolean          default(FALSE), not null
#  published_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'spec_helper'

describe SeasonPiece do
  let(:account) { FactoryGirl.create(:account) }
	let(:season_piece) { FactoryGirl.create(:season_piece, account: account) }
	let(:season) { season_piece.season }
	let(:piece) { season_piece.piece }
	
	before do
		Account.current_id = account.id
		@season_piece = FactoryGirl.build(:season_piece)
	end
	
	subject { @season_piece }

	context "accessible attributes" do
  	it { should respond_to(:account) }
		it { should respond_to(:season) }
  	it { should respond_to(:piece) }
  	it { should respond_to(:casts) }
		it { should respond_to(:published) }
		it { should respond_to(:published_at) }
		
  	it "should not allow access to account_id" do
      expect do
        SeasonPiece.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { season_piece.update_attribute(:account_id, new_account.id) }
			
			it { season_piece.reload.account_id.should == account.id }
		end
		
		it "should not allow access to season_id" do
      expect do
        SeasonPiece.new(season_id: season.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    it "should not allow access to piece_id" do
      expect do
        SeasonPiece.new(piece_id: piece.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
		
    it "should not allow access to published_at" do
      expect do
        SeasonPiece.new(published_at: Time.zone.now)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
		
  	it "published is false when created" do
  		season_piece.reload.published.should be_false
  	end
  end

	context "(Invalid)" do
		it "when account_id is blank" do
  		@season_piece.account_id = " "
  		should_not be_valid
  	end
		
		it "when season is blank" do
  		@season_piece.season_id = " "
  		should_not be_valid
  	end
  	
  	it "when piece is blank" do
  		@season_piece.piece_id = " "
  		should_not be_valid
  	end
  	
  	it "when published is blank" do
  		@season_piece.published = ""
  		should_not be_valid
  	end
		
  	it "when published_at is invalid" do
  		dts = ["abc", "2/31/2012", "13:00:00"]
  		dts.each do |invalid_datetime|
  			@season_piece.published_at = invalid_datetime
  			should_not be_valid
  		end
		end
	end
	
  context "(Associations)" do
		it "has one account" do
			season_piece.reload.account.should == account
		end
		
		it "has one season" do
			season_piece.reload.season.should == season
		end
		
		it "has one piece" do
			season_piece.reload.piece.should == piece
		end
		
		describe "casts" do
			let!(:second_cast) { FactoryGirl.create(:cast, account: account, season_piece: season_piece) }
			let!(:first_cast) { FactoryGirl.create(:cast, account: account, season_piece: season_piece) }
	
			it "has multiple casts" do
				season_piece.casts.count.should == 2
			end
			
			it "deletes associated casts" do
				casts = season_piece.casts
				season_piece.destroy
				casts.each do |cast|
					Cast.find_by_id(cast.id).should be_nil
				end
			end
		end
  end
	
  context "correct value is returned for" do
		it "published?" do
			season_piece.reload.published?.should be_false
		end
	end
	
	context "(Uniqueness)" do
  	it "by Season/Piece" do
  		@season_piece.season = season_piece.season
	  	@season_piece.piece = season_piece.piece
	  	should_not be_valid
  	end
	end
	
	describe "(Scopes)" do
		before do
			SeasonPiece.unscoped.delete_all
		end
		let!(:season_piece1) { FactoryGirl.create(:season_piece, account: account) }
		let!(:season_piece2) { FactoryGirl.create(:season_piece, :published, account: account) }
		let!(:season_piece_wrong_acnt) { FactoryGirl.create(:season_piece, account: FactoryGirl.create(:account)) }
		
		describe "default_scope" do
			it "returns the records in current account" do
				season_pieces = SeasonPiece.all
				season_pieces.count.should == 2
				season_pieces.should include(season_piece1)
				season_pieces.should include(season_piece2)
				season_pieces.should_not include(season_piece_wrong_acnt)
			end
		end
		
		describe "published_casting" do
			it "returns the published records" do
				season_pieces = SeasonPiece.unscoped.published_casting
				season_pieces.count.should == 1
				season_pieces.should_not include(season_piece1)
				season_pieces.should include(season_piece2)
				season_pieces.should_not include(season_piece_wrong_acnt)
			end
		end
		
		describe "unpublished_casting" do
			it "returns the unpublished records" do
				season_pieces = SeasonPiece.unscoped.unpublished_casting
				season_pieces.count.should == 2
				season_pieces.should include(season_piece1)
				season_pieces.should_not include(season_piece2)
				season_pieces.should include(season_piece_wrong_acnt)
			end
		end
	end
	
	context "(On Create)" do
		it "published_at is set when published" do
			Timecop.freeze
			@published = FactoryGirl.create(:season_piece, :published, account: account)
			@published.published_at.should == Time.zone.now
		end
	end
	
	context "(On Update)" do
		before do
			Timecop.freeze
			@for_update = FactoryGirl.create(:season_piece, account: account)
		end
		
		it "published_at is set when published" do
			@for_update.update_attribute(:published, true)
			
			@for_update.published_at.should == Time.zone.now
		end
	end
end
