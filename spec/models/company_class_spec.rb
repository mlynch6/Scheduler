# == Schema Information
#
# Table name: company_classes
#
#  id          :integer          not null, primary key
#  account_id  :integer          not null
#  season_id   :integer          not null
#  title       :string(30)       not null
#  comment     :text
#  start_at    :datetime         not null
#  duration    :integer          not null
#  end_date    :date             not null
#  location_id :integer          not null
#  monday      :boolean          default(FALSE), not null
#  tuesday     :boolean          default(FALSE), not null
#  wednesday   :boolean          default(FALSE), not null
#  thursday    :boolean          default(FALSE), not null
#  friday      :boolean          default(FALSE), not null
#  saturday    :boolean          default(FALSE), not null
#  sunday      :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe CompanyClass do
	let(:account) { FactoryGirl.create(:account) }
	let(:season) { FactoryGirl.create(:season, account: account) }
	let(:location) { FactoryGirl.create(:location, account: account) }
	let(:company_class) { FactoryGirl.create(:company_class,
											account: account,
											season: season,
											title: 'Company Class 1',
											comment: 'My Description',
											start_date: '01/01/2014',
											start_time: '9:15 AM',
											duration: 60,
											end_date: '01/15/2014',
											location: location,
											monday: true,
											tuesday: false,
											wednesday: true,
											thursday: false,
											friday: true,
											saturday: false,
											sunday: false ) }
	
	before do
		Account.current_id = account.id
		@company_class = FactoryGirl.build(:company_class)
	end
	
	subject { @company_class }
	
	context "accessible attributes" do
		it { should respond_to(:title) }
		it { should respond_to(:comment) }
		it { should respond_to(:start_date) }
		it { should respond_to(:start_time) }
		it { should respond_to(:duration) }
		it { should respond_to(:end_date) }
		it { should respond_to(:end_time) }
		it { should respond_to(:monday) }
		it { should respond_to(:tuesday) }
		it { should respond_to(:wednesday) }
		it { should respond_to(:thursday) }
		it { should respond_to(:friday) }
		it { should respond_to(:saturday) }
		it { should respond_to(:sunday) }
		it { should respond_to(:date_range) }
		it { should respond_to(:time_range) }
  	
  	it { should respond_to(:account) }
  	it { should respond_to(:season) }
		it { should respond_to(:events) }
		it { should respond_to(:location) }
  	
  	it "should not allow access to account_id" do
      expect do
        CompanyClass.new(account_id: account.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
    describe "account_id cannot be changed" do
			let(:new_account) { FactoryGirl.create(:account) }
			before { company_class.update_attribute(:account_id, new_account.id) }
			
			it { company_class.reload.account_id.should == account.id }
		end
		
    it "should not allow access to start_at" do
      expect do
        CompanyClass.new(start_at: Time.zone.now)
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
  		@company_class.account_id = " "
  		should_not be_valid
  	end
		
  	it "when season_id is blank" do
  		@company_class.season_id = " "
  		should_not be_valid
  	end
		
		it "when title is blank" do
  		@company_class.title = " "
  		should_not be_valid
  	end
  	
  	it "when title is too long" do
  		@company_class.title = "a"*31
  		should_not be_valid
  	end
		
		context "when start_date" do
			it "is blank" do
	  		@company_class.start_date = " "
	  		should_not be_valid
	  	end
		
	  	it "is invalid" do
	  		dts = ["abc", "2/31/2012"]
	  		dts.each do |invalid_date|
	  			@company_class.start_date = invalid_date
	  			should_not be_valid
	  		end
			end
		end
	
  	it "when start_time is invalid" do
  		@company_class.start_time = "abc"
  		should_not be_valid
  	end	
  	
  	context "when duration" do
			it "is blank" do
				@company_class.duration = " "
				should_not be_valid
			end
			
			it "not an integer" do
	  		vals = ["abc", 8.6]
	  		vals.each do |invalid_integer|
	  			@company_class.duration = invalid_integer
	  			should_not be_valid
	  		end
	  	end
	  	
	  	it "< 1" do
	  		@company_class.duration = 0
	  		should_not be_valid
	  	end
	  	
	  	it "> 1439 (max min in a day)" do
	  		@company_class.duration = 1440
	  		should_not be_valid
	  	end
		end
		
		context "when end_date" do
			it "is blank" do
	  		@company_class.end_date = " "
	  		should_not be_valid
	  	end
		
	  	it "is invalid" do
	  		dts = ["abc", "2/31/2012"]
	  		dts.each do |invalid_date|
	  			@company_class.end_date = invalid_date
	  			should_not be_valid
	  		end
			end
		
			it "is before start_date" do
				@company_class.start_date = Time.zone.today.to_s
				@company_class.end_date = Time.zone.today - 2.days
		  	should_not be_valid
		  end
		end
		
  	it "when location_id is blank" do
  		@company_class.location_id = " "
  		should_not be_valid
  	end
		
  	it "when monday is blank" do
  		@company_class.monday = ""
  		should_not be_valid
  	end
		
  	it "when tuesday is blank" do
  		@company_class.tuesday = ""
  		should_not be_valid
  	end
		
  	it "when wednesday is blank" do
  		@company_class.wednesday = ""
  		should_not be_valid
  	end
		
  	it "when thursday is blank" do
  		@company_class.thursday = ""
  		should_not be_valid
  	end
		
  	it "when friday is blank" do
  		@company_class.friday = ""
  		should_not be_valid
  	end
		
  	it "when saturday is blank" do
  		@company_class.saturday = ""
  		should_not be_valid
  	end
		
  	it "when sunday is blank" do
  		@company_class.sunday = ""
  		should_not be_valid
  	end
		
  	it "when no Day of Week is selected" do
  		@company_class.sunday = false
			@company_class.monday = false
			@company_class.tuesday = false
			@company_class.wednesday = false
			@company_class.thursday = false
			@company_class.friday = false
			@company_class.saturday = false
  		should_not be_valid
  	end
  end
  
	context "(Associations)" do
  	it "has one account" do
			company_class.reload.account.should == account
		end
		
  	it "has one season" do
			company_class.reload.season.should == season
		end
		
		describe "location" do
	  	it "has one location" do
				company_class.reload.location.should == location
			end
		end
		
  	describe "event" do
			it "has multiple events" do
				company_class.events.count.should == 7
			end
			
			it "deletes associated events" do
				events = company_class.events
				company_class.destroy
				events.each do |event|
					Event.find_by_id(event.id).should be_nil
				end
			end
		end
  end
  
	context "correct value is returned for" do
		it "title" do
	  	company_class.reload.title.should == 'Company Class 1'
	  end
	  
	  it "comment" do
	  	company_class.reload.comment.should == 'My Description'
	  end

	  it "start_date" do
	  	company_class.start_date.should == '01/01/2014'
	  end
		
	  it "start_time" do
	  	company_class.start_time.should == '9:15 AM'
	  end
		
	  it "duration" do
	  	company_class.duration.should == 60
	  end
		
	  it "end_date" do
	  	company_class.end_date.should == Date.new(2014,1,15)
	  end
		
	  it "end_time" do
	  	company_class.end_time.should == '10:15 AM'
	  end
		
	  it "monday" do
	  	company_class.monday.should be_true
	  end
		
	  it "tuesday" do
	  	company_class.tuesday.should be_false
	  end
		
	  it "wednesday" do
	  	company_class.wednesday.should be_true
	  end
		
	  it "thursday" do
	  	company_class.thursday.should be_false
	  end
		
	  it "friday" do
	  	company_class.friday.should be_true
	  end
		
	  it "saturday" do
	  	company_class.saturday.should be_false
	  end
		
	  it "sunday" do
	  	company_class.sunday.should be_false
	  end
		
	  it "date_range" do
	  	company_class.date_range.should == '01/01/2014 to 01/15/2014'
	  end
		
	  it "time_range" do
	  	company_class.time_range.should == '9:15 AM to 10:15 AM'
	  end
		
	  it "days_of_week" do
	  	company_class.days_of_week.should == 'M W F'
			
			company_class.tuesday = true
			company_class.thursday = true
			company_class.saturday = true
			company_class.sunday = true
			company_class.save
			company_class.days_of_week.should == 'Su M T W Th F Sa'
	  end
	end
	
	context "(Methods)" do		
	  describe "search" do
	  	before do
	  		4.times do
					company_class = FactoryGirl.create(:company_class, account: account)
				end
				@season = FactoryGirl.create(:season, account: account)
				@location = FactoryGirl.create(:location, account: account)
				@rhino = FactoryGirl.create(:company_class, 
									account: account, 
									season: @season,
									location: @location,
									title: 'My Rhino Demo')
			end
			
	  	it "returns all records by default" do
	  		query = {}
				CompanyClass.search(query).should == CompanyClass.all
		  end
			
		  describe "on title" do
			  it "returns records with query text in title" do
			  	query = { title: "Rhino" }
					records = CompanyClass.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
		  
		  describe "on season" do
			  it "returns records with selected season" do
			  	query = { season: @season.id }
					records = CompanyClass.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
			
		  describe "on location" do
			  it "returns records with selected location" do
			  	query = { loc: @location.id }
					records = CompanyClass.search(query)
					records.count.should == 1
					records.should include(@rhino)
			  end
			end
	  end
	end

	describe "(Scopes)" do
		before do
			CompanyClass.unscoped.delete_all
		end
		let!(:company_class1) { FactoryGirl.create(:company_class, account: account) }
		let!(:company_class2) { FactoryGirl.create(:company_class, account: account) }
		let!(:company_class_wrong_acnt) { FactoryGirl.create(:company_class, account: FactoryGirl.create(:account) ) }
		
		describe "default_scope" do
			it "returns the records in account" do
				company_classes = CompanyClass.all
				
				company_classes.count.should == 2
				company_classes.should include(company_class1)
				company_classes.should include(company_class2)
			end
		end
	end
end
