# == Schema Information
#
# Table name: lecture_demos
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  season_id  :integer          not null
#  title      :string(30)       not null
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe LectureDemo do
	let(:account) { FactoryGirl.create(:account) }
	let(:season) { FactoryGirl.create(:season, account: account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:lecture_demo) { FactoryGirl.create(:lecture_demo,
											account: account,
											season: season,
											title: 'Lecture Demo 1',
											comment: 'My Description') }
	let!(:event) { FactoryGirl.create(:event, account: account, schedulable: lecture_demo) }
	
	before do
		Account.current_id = account.id
		@lecture_demo = FactoryGirl.build(:lecture_demo)
	end
	
	subject { @lecture_demo }
	
	context "accessible attributes" do
		it { should respond_to(:title) }
		it { should respond_to(:comment) }
		it { should respond_to(:start_date) }
		it { should respond_to(:start_time) }
		it { should respond_to(:duration) }
		it { should respond_to(:time_range) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:season) }
		it { should respond_to(:event) }
		it { should respond_to(:location) }
  	
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
		
		it "when title is blank" do
  		@lecture_demo.title = " "
  		should_not be_valid
  	end
  	
  	it "when title is too long" do
  		@lecture_demo.title = "a"*31
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
		
  	describe "event" do
			it "has one" do
				lecture_demo.event.should == event
			end
			
			it "deletes associated event" do
				e = lecture_demo.event
				lecture_demo.destroy
				Event.find_by_id(e.id).should be_nil
			end
		end
		
		describe "location" do
	  	it "has one location" do
				event.location = location
				event.save
				
				lecture_demo.reload.location.should == location
			end
		end
  end
  
	context "correct value is returned for" do
		it "title" do
	  	lecture_demo.reload.title.should == 'Lecture Demo 1'
	  end
	  
	  it "comment" do
	  	lecture_demo.reload.comment.should == 'My Description'
	  end
	end
	
	context "delegated" do
		let(:e) { lecture_demo.event }
	  it "start_date" do
	  	lecture_demo.start_date.should == e.start_date
	  end
		
	  it "start_time" do
	  	lecture_demo.start_time.should == e.start_time
	  end
		
	  it "duration" do
	  	lecture_demo.duration.should == e.duration
	  end
		
	  it "time_range" do
	  	lecture_demo.time_range.should == e.time_range
	  end
	end
	
	context "(Methods)" do		
	  describe "search" do
	  	before do
	  		4.times do
					demo = FactoryGirl.create(:lecture_demo, account: account)
					event = FactoryGirl.create(:event, account: account, schedulable: demo)
				end
				@season = FactoryGirl.create(:season, account: account)
				@location = FactoryGirl.create(:location, account: account)
				@rhino = FactoryGirl.create(:lecture_demo, 
									account: account, 
									season: @season,
									title: 'My Rhino Demo')
				event = FactoryGirl.create(:event, 
									account: account, 
									location: @location,
									schedulable: @rhino)
			end
			
	  	it "returns all records by default" do
	  		query = {}
				LectureDemo.search(query).should == LectureDemo.all
		  end
			
		  describe "on title" do
			  it "returns records with query text in title" do
			  	query = { title: "Rhino" }
					records = LectureDemo.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
		  
		  describe "on season" do
			  it "returns records with selected season" do
			  	query = { season: @season.id }
					records = LectureDemo.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
			
		  describe "on location" do
			  it "returns records with selected location" do
			  	query = { loc: @location.id }
					records = LectureDemo.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
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
			it "returns the records in account by start_date" do
				demos = LectureDemo.all
				
				demos.count.should == 2
				demos.should include(demo1)
				demos.should include(demo2)
			end
		end
	end
end
