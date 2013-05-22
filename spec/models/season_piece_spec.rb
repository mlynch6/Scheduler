# == Schema Information
#
# Table name: season_pieces
#
#  id         :integer          not null, primary key
#  season_id  :integer          not null
#  piece_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe SeasonPiece do
  let(:account) { FactoryGirl.create(:account) }
	let(:season) { FactoryGirl.create(:season, account: account) }
	let(:piece) { FactoryGirl.create(:piece, account: account) }
	let(:season_piece) { FactoryGirl.create(:season_piece,
											season: season,
											piece: piece) }
	before do
		Account.current_id = account.id
		@season_piece = FactoryGirl.build(:season_piece)
	end
	
	subject { @season_piece }

	context "accessible attributes" do
  	it { should respond_to(:season) }
  	it { should respond_to(:piece) }
		
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
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end

	context "(Invalid)" do
		it "when season is blank" do
  		@season_piece.season_id = " "
  		should_not be_valid
  	end
  	
  	it "when piece is blank" do
  		@season_piece.piece_id = " "
  		should_not be_valid
  	end
  	
  	it "when season/piece uniqueness is violated" do
  		@season_piece.season = season_piece.season
	  	@season_piece.piece = season_piece.piece
	  	should_not be_valid
  	end
	end
	
  context "(Associations)" do
		it "has one season" do
			season_piece.reload.season.should == season
		end
		
		it "has one piece" do
			season_piece.reload.piece.should == piece
		end
  end
end
