# == Schema Information
#
# Table name: casts
#
#  id              :integer          not null, primary key
#  season_piece_id :integer          not null
#  name            :string(20)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe Cast do
  let(:account) { FactoryGirl.create(:account) }
	let(:season) { FactoryGirl.create(:season, account: account) }
	let(:piece) { FactoryGirl.create(:piece, account: account) }
	let(:season_piece) { FactoryGirl.create(:season_piece,
											season: season,
											piece: piece) }
	let(:cast) { FactoryGirl.create(:cast,
											season_piece: season_piece) }
											
	before do
		Account.current_id = account.id
		@cast = FactoryGirl.build(:cast)
	end
	
	subject { @cast }

	context "accessible attributes" do
  	it { should respond_to(:season_piece) }
  	it { should respond_to(:name) }
		
		it "should not allow access to season_piece_id" do
      expect do
        Cast.new(season_piece_id: season_piece.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    it "should not allow access to name" do
      expect do
        Cast.new(name: 'My Name')
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  	
  	it "1st record without a name - name will be defaulted to 'Cast A'" do
  		cast.reload.name.should == "Cast A"
  	end
  	
  	it "2nd record without a name - name will be defaulted to 'Cast B'" do
  		season_piece.casts.delete_all
  		cast1 = season_piece.casts.create
  		cast1.name.should == "Cast A"
  		
  		cast2 = season_piece.casts.create
  		cast2.name.should == "Cast B"
  		season_piece.casts.count.should == 2
  	end
  end

	context "(Invalid)" do
		it "when season_piece is blank" do
  		@cast.season_piece_id = " "
  		should_not be_valid
  	end
  	
  	it "when name is too long" do
  		@cast.name = "a"*21
  		should_not be_valid
  	end
	end
	
  context "(Associations)" do
		it "has one season_piece" do
			cast.reload.season_piece.should == season_piece
		end
  end
  
  context "correct value is returned for" do
		it "name" do
	  	cast.reload.name.should == 'Cast A'
	  end
	end
	
	context "(Uniqueness)" do
		it "by Season/Piece/Name" do
	  	@cast.season_piece = cast.season_piece
		  @cast.name = cast.name
		  should_not be_valid
	  end
  end
  
  describe "(Scopes)" do
		before do
			Cast.delete_all
		end
		let!(:second_cast) { FactoryGirl.create(:cast, season_piece: season_piece, name: "Cast B") }
		let!(:first_cast) { FactoryGirl.create(:cast, season_piece: season_piece, name: "Cast A") }
		let!(:cast_wrong_season) { FactoryGirl.create(:cast, name: 'Cast C') }
		
		describe "default_scope" do
			it "returns the records in alphabetical order" do
				Cast.all.should == [first_cast, second_cast, cast_wrong_season]
			end
		end
	end
end
