# == Schema Information
#
# Table name: lecture_demos
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  season_id  :integer          not null
#  name       :string(50)       not null
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe LectureDemo do
	let(:account) { FactoryGirl.create(:account) }
	let(:season) { FactoryGirl.create(:season, account: account) }
	let(:lecture_demo) { FactoryGirl.create(:lecture_demo,
											account: account,
											season: season,
											name: 'Lecture Demo 1',
											comment: 'My Description') }
	before do
		Account.current_id = account.id
		@lecture_demo = FactoryGirl.build(:lecture_demo)
	end
	
	subject { @lecture_demo }
	
	context "accessible attributes" do
		it { should respond_to(:name) }
		it { should respond_to(:comment) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:season) }
  	
  	it "should not allow access to account_id" do
      expect do
        LectureDemo.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { lecture_demo.update_attribute(:account_id, new_account.id) }
			
			it { lecture_demo.reload.account_id.should == account.id }
		end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end
  
  context "(Invalid)" do
  	it "when account_id is blank" do
  		@lecture_demo.account_id = " "
  		should_not be_valid
  	end
		
  	it "when season_id is blank" do
  		@lecture_demo.season_id = " "
  		should_not be_valid
  	end
		
		it "when name is blank" do
  		@lecture_demo.name = " "
  		should_not be_valid
  	end
  	
  	it "when name is too long" do
  		@lecture_demo.name = "a"*51
  		should_not be_valid
  	end
  end
  
	context "(Associations)" do
  	it "has one account" do
			lecture_demo.reload.account.should == account
		end
		
  	it "has one season" do
			lecture_demo.reload.season.should == season
		end
		
  	it "has one event" do
			pending
			lecture_demo.reload.event.should == season
		end
  end
  
	context "correct value is returned for" do
		it "name" do
	  	lecture_demo.reload.name.should == 'Lecture Demo 1'
	  end
	  
	  it "comment" do
	  	lecture_demo.reload.comment.should == 'My Description'
	  end
	end

	describe "(Scopes)" do
		before do
			LectureDemo.unscoped.delete_all
		end
		let!(:demo1) { FactoryGirl.create(:lecture_demo, account: account) }
		let!(:demo2) { FactoryGirl.create(:lecture_demo, account: account) }
		let!(:demo_wrong_acnt) { FactoryGirl.create(:lecture_demo, account: FactoryGirl.create(:account) ) }
		
		describe "default_scope" do
			it "returns the records in current account" do
				demos = LectureDemo.all
				
				demos.count.should == 2
				demos.should include(demo1)
				demos.should include(demo2)
			end
		end
	end
end
