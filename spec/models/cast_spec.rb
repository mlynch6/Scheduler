# == Schema Information
#
# Table name: casts
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
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
	let!(:char1) { FactoryGirl.create(:character, account: account, piece: piece) }
	let!(:char2) { FactoryGirl.create(:character, account: account, piece: piece) }
	let(:season_piece) { FactoryGirl.create(:season_piece,
											account: account,
											season: season,
											piece: piece) }
	let(:cast) { FactoryGirl.create(:cast,
											account: account,
											season_piece: season_piece) }
											
	before do
		Account.current_id = account.id
		@cast = FactoryGirl.build(:cast)
	end
	
	subject { @cast }

	context "accessible attributes" do
		it { should respond_to(:account) }
  	it { should respond_to(:season_piece) }
  	it { should respond_to(:name) }
		
		it { should respond_to(:castings) }
		
  	it "should not allow access to account_id" do
      expect do
        Cast.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { cast.update_attribute(:account_id, new_account.id) }
			
			it { cast.reload.account_id.should == account.id }
		end
		
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
		it "when account_id is blank" do
  		@cast.account_id = " "
  		should_not be_valid
  	end
		
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
		it "has one account" do
			cast.reload.account.should == account
		end
		
		it "has one season_piece" do
			cast.reload.season_piece.should == season_piece
		end
		
  	describe "castings" do	
			it "has multiple castings" do
				cast.castings.count.should == 2
			end
			
			it "deletes associated castings" do
				castings = cast.castings
				cast.destroy
				castings.each do |casting|
					Castings.find_by_id(casting.id).should be_nil
				end
			end
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
			
			wrong_acnt = FactoryGirl.create(:account)
			Account.current_id = wrong_acnt.id
			season_wrong_acnt = FactoryGirl.create(:season, account: wrong_acnt)
			piece_wrong_acnt = FactoryGirl.create(:piece, account: wrong_acnt)
			char_wrong_acnt = FactoryGirl.create(:character, account: wrong_acnt, piece: piece_wrong_acnt)
			season_piece_wrong_acnt = FactoryGirl.create(:season_piece,
													account: wrong_acnt,
													season: season_wrong_acnt,
													piece: piece_wrong_acnt)
			@cast_wrong_acnt = FactoryGirl.create(:cast,
													account: wrong_acnt,
													season_piece: season_piece_wrong_acnt)
			Account.current_id = account.id
		end
		let!(:second_cast) { FactoryGirl.create(:cast, account: account, season_piece: season_piece, name: "Cast B") }
		let!(:first_cast) { FactoryGirl.create(:cast, account: account, season_piece: season_piece, name: "Cast A") }
		
		describe "default_scope" do
			it "returns the records for current account in alphabetical order" do
				casts = Cast.all
				casts.count.should == 2
				casts.should == [first_cast, second_cast]
				casts.should_not include(@cast_wrong_acnt)
			end
		end
	end
end
