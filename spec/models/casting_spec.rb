# == Schema Information
#
# Table name: castings
#
#  id           :integer          not null, primary key
#  account_id   :integer          not null
#  cast_id      :integer          not null
#  character_id :integer          not null
#  person_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'spec_helper'

describe Casting do
	let(:account) { FactoryGirl.create(:account) }
	let(:person) { FactoryGirl.create(:employee, account: account) }
	let(:season) { FactoryGirl.create(:season, account: account) }
	let!(:piece) { FactoryGirl.create(:piece, account: account) }
	let!(:character) { FactoryGirl.create(:character, account: account, piece: piece) }
	let!(:season_piece) { FactoryGirl.create(:season_piece, account: account, season: season, piece: piece) }
	
	before do
		Account.current_id = account.id
		@casting = FactoryGirl.build(:casting)
		@cast= FactoryGirl.create(:cast, account: account, season_piece: season_piece)
		@c = @cast.castings.first
		@c.update_attribute(:person_id, person.id)
	end
	
	subject { @casting }

	context "accessible attributes" do
		it { should respond_to(:account) }
		it { should respond_to(:cast) }
		it { should respond_to(:character) }
		it { should respond_to(:person) }
		
  	it "should not allow access to account_id" do
      expect do
        Casting.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
		#     describe "account_id cannot be changed" do
		# 	let(:new_account) { FactoryGirl.create(:account) }
		# 	before { @c.update_attribute(:account_id, new_account.id) }
		# 	
		# 	it do
		# 		@c.reload.account_id.should == account.id
		# 	end
		# end
		
		it "should not allow access to cast_id" do
			expect do
				Casting.new(cast_id: @cast.id)
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
  		@casting.account_id = " "
  		should_not be_valid
  	end
		
		it "when cast_id is blank" do
			@casting.cast_id = " "
			should_not be_valid
		end
  	
  	it "when character_id is blank" do
  		@casting.character_id = " "
  		should_not be_valid
  	end
	end
	
	context "(Uniqueness)" do
		it "by Cast/Character" do
			@casting.cast = @c.cast
			@casting.character = @c.character
			should_not be_valid
		end
	end
	
  context "(Associations)" do
		it "has one account" do
			@c.reload.account.should == account
		end
		
		it "has one cast" do
			@c.reload.cast.should == @cast
		end
		
		it "has one character" do
			@c.reload.character.should == character
		end
		
		it "has one person" do
			@c.reload.person.should == person
		end
  end
	
	describe "(Scopes)" do
		before do
			account.castings.delete_all
		end
		let!(:piece1) { FactoryGirl.create(:piece, account: account) }
		let!(:character1) { FactoryGirl.create(:character, account: account, piece: piece1) }
		let!(:season_piece1) { FactoryGirl.create(:season_piece, season: season, piece: piece1) }
		let!(:cast1) { FactoryGirl.create(:cast, season_piece: season_piece1) }
		
		let!(:piece2) { FactoryGirl.create(:piece, account: account) }
		let!(:character2) { FactoryGirl.create(:character, account: account, piece: piece2) }
		let!(:season_piece2) { FactoryGirl.create(:season_piece, season: season, piece: piece2) }
		let!(:cast2) { FactoryGirl.create(:cast, season_piece: season_piece2) }
		
		let!(:wrong_acnt) { FactoryGirl.create(:account) }
		let!(:season_wrong_acnt) { FactoryGirl.create(:season, account: wrong_acnt) }
		let!(:piece_wrong_acnt) { FactoryGirl.create(:piece, account: wrong_acnt) }
		let!(:character_wrong_acnt) { FactoryGirl.create(:character, account: wrong_acnt, piece: piece_wrong_acnt) }
		let!(:season_piece_wrong_acnt) { FactoryGirl.create(:season_piece, season: season_wrong_acnt, piece: piece_wrong_acnt) }
		let!(:cast_wrong_acnt) { FactoryGirl.create(:cast, season_piece: season_piece_wrong_acnt) }
		
		describe "default_scope" do
			it "returns the records in current account" do
				castings = Casting.all
				castings.count.should == 2
				castings.should include(cast1.castings.first)
				castings.should include(cast2.castings.first)
				castings.should_not include(cast_wrong_acnt.castings.first)
			end
		end
	end
end
