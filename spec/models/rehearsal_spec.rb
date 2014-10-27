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

describe Rehearsal do
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
	let(:event) { FactoryGirl.create(:event, account: account, schedulable: rehearsal,
											start_time: '10:15 am',
											duration: 60) }
	
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
		it { should respond_to(:break_duration) }
		it { should respond_to(:break_time_range) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:season) }
		it { should respond_to(:piece) }
		it { should respond_to(:scene) }
		it { should respond_to(:event) }
		it { should respond_to(:location) }
		it { should respond_to(:artist_invitations) }
		it { should respond_to(:artists) }
		it { should respond_to(:musician_invitations) }
		it { should respond_to(:musicians) }
  	
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
		
		it "has no contract" do
			account.agma_contract.destroy
			should be_valid
		end
		
		it "when 'Rehearsal Start' is blank on contract" do
			account.agma_contract.rehearsal_start_min = " "
			account.agma_contract.save
			@rehearsal.event.start_time = '8 am'
			
			should be_valid
		end
		
		it "when start_time = contract's 'Rehearsal Start'" do
			account.agma_contract.rehearsal_start_min = 570	#9:30 AM
			account.agma_contract.save
			@rehearsal.event.start_time = '9:30 AM'
			
			should be_valid
		end
		
		it "when 'Rehearsal End' is blank on contract" do
			account.agma_contract.rehearsal_end_min = " "
			account.agma_contract.save
			@rehearsal.event.start_time = '6 pm'
			@rehearsal.event.duration = 60
			
			should be_valid
		end
		
		it "when end_time = contract's 'Rehearsal End'" do
			account.agma_contract.rehearsal_end_min = 1110	#6:30 PM
			account.agma_contract.save
			@rehearsal.event.start_time = '6 pm'
			@rehearsal.event.duration = 30
			
			should be_valid
		end
		
		it "when 'Increment' is blank on contract" do
			account.agma_contract.rehearsal_increment_min = " "
			account.agma_contract.save
			@rehearsal.event.duration = 18
			
			should be_valid
		end
		
		it "when duration is a multiple of contract's 'Increment'" do
			account.agma_contract.rehearsal_increment_min = 30
			account.agma_contract.save
			
  		durations = [30, 60, 90]
  		durations.each do |valid_duration|
  			@rehearsal.event.duration = valid_duration
  			should be_valid
  		end
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
		
		it "when start_time is before contract's 'Rehearsal Start'" do
			account.agma_contract.rehearsal_start_min = 570	#9:30 AM
			account.agma_contract.save
			@rehearsal.event.start_time = '9 AM'
			
			should_not be_valid
		end
		
		it "when end_time is after contract's 'Rehearsal End'" do
			account.agma_contract.rehearsal_end_min = 1110	#6:30 PM
			account.agma_contract.save
			@rehearsal.event.start_time = '6 pm'
			@rehearsal.event.duration = 60
			
			should_not be_valid
		end
		
		it "when duration not a multiple of contract's 'Increment'" do
			account.agma_contract.rehearsal_increment_min = 30
			account.agma_contract.save
			
  		durations = [18, 45]
  		durations.each do |invalid_duration|
  			@rehearsal.event.duration = invalid_duration
  			should_not be_valid
  		end
		end
  end
  
	context "(Associations)" do
		describe "has no" do
			it "scene" do
				rehearsal.reload.scene.should be_nil
			end
		end
		
		describe "has one" do
	  	it "has one account" do
				rehearsal.reload.account.should == account
			end
		
	  	it "has one season" do
				rehearsal.reload.season.should == season
			end
		
	  	it "has one piece" do
				rehearsal.reload.piece.should == piece
			end
		
			it "has one scene" do
				rehearsal.scene = scene
				rehearsal.save
				rehearsal.reload.scene.should == scene
			end
			
			it "event" do
				event.reload
				rehearsal.reload.event.should == event
			end
			
	  	it "location" do
				event.location = location
				event.save
				
				rehearsal.reload.location.should == location
			end
		end
		
		describe "has many" do
			before do
				3.times { FactoryGirl.create(:invitation, :artist, account: account, event: event) }
				2.times { FactoryGirl.create(:invitation, :musician, account: account, event: event) }
			end
			
			it "artist_invitations" do
				rehearsal.artist_invitations.count.should == 3
			end
			
			it "artists" do
				rehearsal.artists.count.should == 3
			end
			
			it "musician_invitations" do
				rehearsal.musician_invitations.count.should == 2
			end
			
			it "musicians" do
				rehearsal.musicians.count.should == 2
			end
		end
		
  	describe "deletes associated" do
			it "events" do
				e = rehearsal.event
				rehearsal.destroy
				Event.find_by_id(e.id).should be_nil
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
		
	  describe "time_range" do
			it "without Rehearsal Break" do
				event.reload
		  	rehearsal.reload.time_range.should == "10:15 AM to 11:15 AM"
			end
			
			it "with Rehearsal Break" do
				contract = FactoryGirl.create(:rehearsal_break, 
						agma_contract: account.agma_contract, 
						break_min: 5,
						duration_min: event.duration)
		  	rehearsal.reload.time_range.should == "10:15 AM to 11:10 AM"
			end
	  end
		
	  describe "break_duration" do
			it "without Rehearsal Break" do
				event.reload
		  	rehearsal.reload.break_duration.should == 0
			end
			
			it "with Rehearsal Break" do
				contract = FactoryGirl.create(:rehearsal_break, 
						agma_contract: account.agma_contract, 
						break_min: 5,
						duration_min: event.duration)
		  	rehearsal.reload.break_duration.should == 5
			end
	  end
		
	  describe "break_time_range" do
			it "without Rehearsal Break" do
				event.reload
		  	rehearsal.reload.break_time_range.should be_nil
			end
			
			it "with Rehearsal Break" do
				contract = FactoryGirl.create(:rehearsal_break, 
						agma_contract: account.agma_contract, 
						break_min: 5,
						duration_min: event.duration)
		  	rehearsal.reload.break_time_range.should == "11:10 AM to 11:15 AM"
			end
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
