# == Schema Information
#
# Table name: costume_fittings
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

describe CostumeFitting do
	let(:account) { FactoryGirl.create(:account) }
	let(:season) { FactoryGirl.create(:season, account: account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:costume_fitting) { FactoryGirl.create(:costume_fitting,
											account: account,
											season: season,
											title: 'Costume Fitting 1',
											comment: 'My Description') }
	let!(:event) { FactoryGirl.create(:event, account: account, schedulable: costume_fitting) }
	
	before do
		Account.current_id = account.id
		@costume_fitting = FactoryGirl.build(:costume_fitting)
	end
	
	subject { @costume_fitting }
	
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
        CostumeFitting.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { costume_fitting.update_attribute(:account_id, new_account.id) }
			
			it { costume_fitting.reload.account_id.should == account.id }
		end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
		
		it "has no contract" do
			account.agma_contract.destroy
			should be_valid
		end
		
		it "when 'Increment' is blank on contract" do
			account.agma_contract.costume_increment_min = " "
			account.agma_contract.save
			@costume_fitting.event.duration = 18
			
			should be_valid
		end
		
		it "when duration is a multiple of contract's 'Increment'" do
			account.agma_contract.costume_increment_min = 15
			account.agma_contract.save
			
  		durations = [15, 30, 45]
  		durations.each do |valid_duration|
  			@costume_fitting.event.duration = valid_duration
  			should be_valid
  		end
		end
  end
  
  context "(Invalid)" do
  	it "when account_id is blank" do
  		@costume_fitting.account_id = " "
  		should_not be_valid
  	end
		
  	it "when season_id is blank" do
  		@costume_fitting.season_id = " "
  		should_not be_valid
  	end
		
		it "when title is blank" do
  		@costume_fitting.title = " "
  		should_not be_valid
  	end
  	
  	it "when title is too long" do
  		@costume_fitting.title = "a"*31
  		should_not be_valid
  	end
		
		it "when duration not a multiple of contract's 'Increment'" do
			account.agma_contract.costume_increment_min = 15
			account.agma_contract.save
			
  		durations = [10, 20, 25]
  		durations.each do |invalid_duration|
  			@costume_fitting.event.duration = invalid_duration
  			should_not be_valid
  		end
		end
  end
  
	context "(Associations)" do
  	it "has one account" do
			costume_fitting.reload.account.should == account
		end
		
  	it "has one season" do
			costume_fitting.reload.season.should == season
		end
		
  	describe "event" do
			it "has one" do
				costume_fitting.reload.event.should == event
			end
			
			it "deletes associated event" do
				e = costume_fitting.event
				costume_fitting.destroy
				Event.find_by_id(e.id).should be_nil
			end
		end
		
		describe "location" do
	  	it "has one location" do
				event.location = location
				event.save
				
				costume_fitting.reload.location.should == location
			end
		end
  end
  
	context "correct value is returned for" do
		it "title" do
	  	costume_fitting.reload.title.should == 'Costume Fitting 1'
	  end
	  
	  it "comment" do
	  	costume_fitting.reload.comment.should == 'My Description'
	  end
	end
	
	context "delegated" do
		let(:e) { costume_fitting.event }
	  it "start_date" do
	  	costume_fitting.start_date.should == e.start_date
	  end
		
	  it "start_time" do
	  	costume_fitting.start_time.should == e.start_time
	  end
		
	  it "duration" do
	  	costume_fitting.duration.should == e.duration
	  end
		
	  it "time_range" do
	  	costume_fitting.time_range.should == e.time_range
	  end
	end
	
	context "(Methods)" do		
	  describe "search" do
	  	before do
	  		4.times do
					fitting = FactoryGirl.create(:costume_fitting, account: account)
					event = FactoryGirl.create(:event, account: account, schedulable: fitting)
				end
				@season = FactoryGirl.create(:season, account: account)
				@location = FactoryGirl.create(:location, account: account)
				@rhino = FactoryGirl.create(:costume_fitting, 
									account: account, 
									season: @season,
									title: 'My Rhino Fitting')
				event = FactoryGirl.create(:event, 
									account: account, 
									location: @location,
									schedulable: @rhino)
			end
			
	  	it "returns all records by default" do
	  		query = {}
				CostumeFitting.search(query).should == CostumeFitting.all
		  end
			
		  describe "on title" do
			  it "returns records with query text in title" do
			  	query = { title: "Rhino" }
					records = CostumeFitting.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
		  
		  describe "on season" do
			  it "returns records with selected season" do
			  	query = { season: @season.id }
					records = CostumeFitting.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
			
		  describe "on location" do
			  it "returns records with selected location" do
			  	query = { loc: @location.id }
					records = CostumeFitting.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
	  end
	end

	describe "(Scopes)" do
		before do
			CostumeFitting.unscoped.delete_all
		end
		let!(:fitting1) { FactoryGirl.create(:costume_fitting, account: account) }
		let!(:fitting2) { FactoryGirl.create(:costume_fitting, account: account) }
		let!(:fitting_wrong_acnt) { FactoryGirl.create(:costume_fitting, account: FactoryGirl.create(:account) ) }
		
		describe "default_scope" do
			it "returns the records in account by start_date" do
				fittings = CostumeFitting.all
				
				fittings.count.should == 2
				fittings.should include(fitting1)
				fittings.should include(fitting2)
			end
		end
	end
end
