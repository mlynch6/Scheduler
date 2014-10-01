# == Schema Information
#
# Table name: rehearsals
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  season_id  :integer          not null
#  title      :string(30)       not null
#  piece_id   :integer          not null
#  scene_id   :integer
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Rehearsal, focus: true do
	let(:account) { FactoryGirl.create(:account) }
	let(:season) { FactoryGirl.create(:season, account: account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:piece) { FactoryGirl.create(:piece, account: account) }
	let(:scene) { FactoryGirl.create(:scene, piece: piece, account: account) }
	let(:rehearsal) { FactoryGirl.create(:rehearsal,
											account: account,
											season: season,
											title: 'Rehearsal 1',
											piece: piece,
											comment: 'My Description') }
	let!(:event) { FactoryGirl.create(:event, account: account, schedulable: rehearsal) }
	
	before do
		Account.current_id = account.id
		@rehearsal = FactoryGirl.build(:rehearsal)
	end
	
	subject { @rehearsal }
	
	context "accessible attributes" do
		it { should respond_to(:title) }
		it { should respond_to(:comment) }
		it { should respond_to(:start_date) }
		it { should respond_to(:start_time) }
		it { should respond_to(:duration) }
		it { should respond_to(:time_range) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:season) }
		it { should respond_to(:piece) }
		it { should respond_to(:scene) }
		it { should respond_to(:event) }
		it { should respond_to(:location) }
  	
  	it "should not allow access to account_id" do
      expect do
        Rehearsal.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { rehearsal.update_attribute(:account_id, new_account.id) }
			
			it { rehearsal.reload.account_id.should == account.id }
		end
  end
	
  context "(Valid)" do  	
  	it "with minimum attributes" do
  		should be_valid
  	end
  end
  
  context "(Invalid)" do
  	it "when account_id is blank" do
  		@rehearsal.account_id = " "
  		should_not be_valid
  	end
		
  	it "when season_id is blank" do
  		@rehearsal.season_id = " "
  		should_not be_valid
  	end
		
		it "when title is blank" do
  		@rehearsal.title = " "
  		should_not be_valid
  	end
  	
  	it "when title is too long" do
  		@rehearsal.title = "a"*31
  		should_not be_valid
  	end
		
  	it "when piece_id is blank" do
  		@rehearsal.piece_id = " "
  		should_not be_valid
  	end
  end
  
	context "(Associations)" do
  	it "has one account" do
			rehearsal.reload.account.should == account
		end
		
  	it "has one season" do
			rehearsal.reload.season.should == season
		end
		
  	it "has one piece" do
			rehearsal.reload.piece.should == piece
		end
		
		it "has no scene" do
			rehearsal.reload.scene.should be_nil
		end
		
		it "has one scene" do
			rehearsal.scene = scene
			rehearsal.save
			rehearsal.reload.scene.should == scene
		end
		
  	describe "event" do
			it "has one" do
				rehearsal.event.should == event
			end
			
			it "deletes associated event" do
				e = rehearsal.event
				rehearsal.destroy
				Event.find_by_id(e.id).should be_nil
			end
		end
		
		describe "location" do
	  	it "has one location" do
				event.location = location
				event.save
				
				rehearsal.reload.location.should == location
			end
		end
  end
  
	context "correct value is returned for" do
		it "title" do
	  	rehearsal.reload.title.should == 'Rehearsal 1'
	  end
	  
	  it "comment" do
	  	rehearsal.reload.comment.should == 'My Description'
	  end
	end
	
	context "delegated" do
		let(:e) { rehearsal.event }
	  it "start_date" do
	  	rehearsal.start_date.should == e.start_date
	  end
		
	  it "start_time" do
	  	rehearsal.start_time.should == e.start_time
	  end
		
	  it "duration" do
	  	rehearsal.duration.should == e.duration
	  end
		
	  it "time_range" do
	  	rehearsal.time_range.should == e.time_range
	  end
	end
	
	context "(Methods)" do		
	  describe "search" do
	  	before do
	  		4.times do
					rehearsal = FactoryGirl.create(:rehearsal, account: account)
					event = FactoryGirl.create(:event, account: account, schedulable: rehearsal)
				end
				@season = FactoryGirl.create(:season, account: account)
				@piece = FactoryGirl.create(:piece, account: account)
				@location = FactoryGirl.create(:location, account: account)
				@rhino = FactoryGirl.create(:rehearsal, 
									account: account, 
									season: @season,
									piece: @piece,
									title: 'My Rhino Rehearsal')
				event = FactoryGirl.create(:event, 
									account: account, 
									location: @location,
									schedulable: @rhino)
			end
			
	  	it "returns all records by default" do
	  		query = {}
				Rehearsal.search(query).should == Rehearsal.all
		  end
			
		  describe "on title" do
			  it "returns records with query text in title" do
			  	query = { title: "Rhino" }
					records = Rehearsal.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
		  
		  describe "on season" do
			  it "returns records with selected season" do
			  	query = { season: @season.id }
					records = Rehearsal.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
			
		  describe "on location" do
			  it "returns records with selected location" do
			  	query = { loc: @location.id }
					records = Rehearsal.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
			
		  describe "on piece" do
			  it "returns records with selected piece" do
			  	query = { piece: @piece.id }
					records = Rehearsal.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
	  end
	end

	describe "(Scopes)" do
		before do
			Rehearsal.unscoped.delete_all
		end
		let!(:rehearsal1) { FactoryGirl.create(:rehearsal, account: account) }
		let!(:rehearsal2) { FactoryGirl.create(:rehearsal, account: account) }
		let!(:rehearsal_wrong_acnt) { FactoryGirl.create(:rehearsal, account: FactoryGirl.create(:account) ) }
		
		describe "default_scope" do
			it "returns the records in account by start_date" do
				rehearsals = Rehearsal.all
				
				rehearsals.count.should == 2
				rehearsals.should include(rehearsal1)
				rehearsals.should include(rehearsal2)
			end
		end
	end
end
