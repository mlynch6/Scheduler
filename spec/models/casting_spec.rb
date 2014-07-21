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
	
	before do
		Account.current_id = account.id
		@casting = FactoryGirl.build(:casting)
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
		
		it "should not allow access to cast_id" do
			@cast= FactoryGirl.create(:cast, account: account)
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
			c = FactoryGirl.create(:casting)
			@casting.cast = c.cast
			@casting.character = c.character
			should_not be_valid
		end
	end
	
  context "(Associations)" do
		before do
			@cast = FactoryGirl.create(:cast, account: account)
			@character = FactoryGirl.create(:character, account: account)
			@person = FactoryGirl.create(:person, account: account)
			@c = FactoryGirl.create(:casting, 
					account: account, 
					cast: @cast, 
					character: @character, 
					person: @person)
		end
		
		it "has one account" do
			@c.reload.account.should == account
		end
		
		it "has one cast" do
			@c.reload.cast.should == @cast
		end
		
		it "has one character" do
			@c.reload.character.should == @character
		end
		
		it "has one person" do
			@c.reload.person.should == @person
		end
  end
	
	describe "(Scopes)" do
		before do
			Casting.unscoped.delete_all
		end
		let!(:casting1) { FactoryGirl.create(:casting, account: account) }
		let!(:casting2) { FactoryGirl.create(:casting, account: account) }
		let!(:casting_wrong_acnt) { FactoryGirl.create(:casting, account: FactoryGirl.create(:account)) }
		
		describe "default_scope" do
			it "returns the records in current account" do
				castings = Casting.all
				castings.count.should == 2
				castings.should include(casting1)
				castings.should include(casting2)
				castings.should_not include(casting_wrong_acnt)
			end
		end
	end
end
