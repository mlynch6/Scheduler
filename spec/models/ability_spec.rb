require 'spec_helper'
require 'cancan/matchers'

describe Ability do
	before do
		Rails.application.load_seed
		@user = nil
	end
	
	let(:ability) { Ability.new(@user) }

	subject { ability }

	context "Super Administrator:" do
		before do
			@user = FactoryGirl.create(:user, :superadmin)
		end
	
		it "should be able to manage everything" do
			ability.should be_able_to :manage, :all
		end
	end
	
	context "Guest (not logged in):" do
		it "should be able to manage Static Pages" do
			should be_able_to(:manage, :static_page)
		end
		
		it "should be able to Login" do
			should be_able_to(:create, :session)
		end
		
		it "should be able to Reset Password" do
			should be_able_to(:manage, :password_reset)
		end
		
		it "should be able to Signup for a new Account" do
			should be_able_to(:create, Account.new)
		end
	end
	
	context "Any User (logged in):" do
		before do
			@user = FactoryGirl.create(:user)
			Account.current_id = @user.account_id
		end

		it "should be able to Logout" do
			should be_able_to :destroy, :session
		end
		
		it "should be able to change their Password" do
			should be_able_to :create, :password
		end
		
		it "should be able to read the Dashboard" do
			should be_able_to :read, :dashboard
		end

		context "for Person" do
			it "should be able to read their own Person Profile" do
				person = @user.person
				should be_able_to :show, person
			end
		
			it "should NOT be able to read other Person Profiles" do
				other_person = FactoryGirl.create(:person, account: @user.account)
				should_not be_able_to :show, other_person
			end
		end
		
		context "for Employees" do
			it "should be able to show their own Employee Profile" do
				employee = @user.person.profile
				should be_able_to :show, employee
			end
		
			it "should NOT be able to show other Employee Profiles" do
				other_employee = FactoryGirl.create(:person, account: @user.account).profile
				should_not be_able_to :show, other_employee
			end
		end
		
		context "for Addresses" do
			it "should be able to manage their own Addresses" do
				employee = @user.person.profile
				should be_able_to :manage, employee.addresses.build
			end
		
			it "should NOT be able to manage other Employee's Addresses" do
				other_employee = FactoryGirl.create(:person, account: @user.account).profile
				should_not be_able_to :manage, other_employee.addresses.build
			end
		
			it "should NOT be able to manage an Account's Addresses" do
				should_not be_able_to :manage, @user.account.addresses.build
			end
		end
		
		context "for Phone Numbers" do
			it "should be able to manage their own Phone Numbers" do
				employee = @user.person.profile
				should be_able_to :manage, employee.phones.build
			end
		
			it "should NOT be able to manage other Employee's Phone Numbers" do
				other_employee = FactoryGirl.create(:person, account: @user.account).profile
				should_not be_able_to :manage, other_employee.phones.build
			end
		
			it "should NOT be able to manage an Account's Phone Numbers" do
				should_not be_able_to :manage, @user.account.phones.build
			end
		end
	end
	
	context "Manage Employees:" do
		before do
			@user = FactoryGirl.create(:user, :with_role, role_name: 'Manage Employees')
			Account.current_id = @user.account_id
			
			@employee = FactoryGirl.create(:person, account: @user.account).profile
		end
		
		it "should be able to read People" do
			should be_able_to :read, @employee.person
		end
		
		it "should be able to create/read/update/activate/inactivate Employees" do
			should be_able_to :create, Employee.new
			should be_able_to :read, @employee
			should be_able_to :update, @employee
			should be_able_to :activate, @employee
			should be_able_to :inactivate, @employee
		end
		
		context "for Addresses" do 
			it "should be able to create/read/update/destroy an Employee Address" do
				should be_able_to :crud, @employee.addresses.build
			end
		
			it "should NOT be able to create/read/update/destroy an Account's Addresses" do
				should_not be_able_to :crud, @user.account.addresses.build
			end
		end
		
		context "for Phone Numbers" do
			it "should be able to create/read/update/destroy an Employee Phone Number" do
				should be_able_to :crud, @employee.phones.build
			end
		
			it "should NOT be able to create/read/update/destroy an Account's Phone NUmber" do
				should_not be_able_to :crud, @user.account.phones.build
			end
		end
	end
	
	context "Manage Logins:" do
		before do
			@user = FactoryGirl.create(:user, :with_role, role_name: 'Manage Logins')
			Account.current_id = @user.account_id
		end
		
		it "should be able to read People" do
			should be_able_to :read, Person
		end
		
		it "should be able to read Employee" do
			should be_able_to :read, Employee
		end
		
		it "should be able to manage User" do
			should be_able_to :manage, User
		end
	end
	
	context "Manage Locations:" do
		before do
			@user = FactoryGirl.create(:user, :with_role, role_name: 'Manage Locations')
			Account.current_id = @user.account_id
		end
		
		it "should be able to manage Locations" do
			should be_able_to :manage, Location
		end
	end
	
	context "Manage Seasons:" do
		before do
			@user = FactoryGirl.create(:user, :with_role, role_name: 'Manage Seasons')
			Account.current_id = @user.account_id
		end
		
		it "should be able to manage Seasons" do
			should be_able_to :manage, Season
		end
	end
	
	context "Manage Pieces:" do
		before do
			@user = FactoryGirl.create(:user, :with_role, role_name: 'Manage Pieces')
			Account.current_id = @user.account_id
		end
		
		it "should be able to manage Pieces" do
			should be_able_to :manage, Piece
		end
		
		it "should be able to manage a Piece's Characters" do
			should be_able_to :manage, Character
		end
		
		it "should be able to manage a Piece's Scenes" do
			should be_able_to :manage, Scene
		end
	end
	
	context "Manage AGMA Contract:" do
		before do
			@user = FactoryGirl.create(:user, :with_role, role_name: 'Manage AGMA Contract')
			Account.current_id = @user.account_id
		end
		
		it "should be able to read/update AGMA Contract" do
			should be_able_to :read, AgmaContract
			should be_able_to :update, AgmaContract
		end
		
		it "should be able to read/update AGMA Contract's Rehearsal Week" do
			should be_able_to :read, :contract_rehearsal_week
			should be_able_to :update, :contract_rehearsal_week
		end
		
		it "should be able to read/update AGMA Contract's Company Class" do
			should be_able_to :read, :contract_company_class
			should be_able_to :update, :contract_company_class
		end
		
		it "should be able to read/update AGMA Contract's Costume Fittings" do
			should be_able_to :read, :contract_costume_fitting
			should be_able_to :update, :contract_costume_fitting
		end
		
		it "should be able to read/update AGMA Contract's Lecture Demos" do
			should be_able_to :read, :contract_lecture_demo
			should be_able_to :update, :contract_lecture_demo
		end
		
		it "should be able to manage Rehearsal Breaks" do
			should be_able_to :manage, RehearsalBreak
		end
	end
	
	context "Schedule Company Classes:" do
		before do
			@user = FactoryGirl.create(:user, :with_role, role_name: 'Schedule Company Classes')
			@class = FactoryGirl.create(:company_class, account: @user.account)
		end
		
		it "should be able to read/destroy Company Class Events" do
			should be_able_to :read, @class.events.first
			should be_able_to :destroy, @class.events.first
		end
		
		it "should NOT be able to manage other types of Events" do
			@event = FactoryGirl.create(:event, account: @user.account)
			should_not be_able_to :manage, @event
		end
		
		it "should be able to manage Company Classes" do
			should be_able_to :manage, CompanyClass
		end
	end
	
	context "Schedule Costume Fittings:" do
		before do
			@user = FactoryGirl.create(:user, :with_role, role_name: 'Schedule Costume Fittings')
			Account.current_id = @user.account_id
			@fitting = FactoryGirl.create(:costume_fitting, account: @user.account)
			@event = FactoryGirl.create(:event, account: @user.account, schedulable: @fitting)
		end
		
		it "should be able to manage Costume Fitting Events" do
			should be_able_to :read, @fitting.event
		end
		
		it "should NOT be able to read other types of Events" do
			@event = FactoryGirl.create(:event, account: @user.account)
			should_not be_able_to :read, @event
		end
		
		it "should be able to manage Costume Fittings" do
			should be_able_to :manage, CostumeFitting
		end
	end
	
	context "Schedule Rehearsals:" do
		before do
			@user = FactoryGirl.create(:user, :with_role, role_name: 'Schedule Rehearsals')
			Account.current_id = @user.account_id
			@rehearsal = FactoryGirl.create(:rehearsal, account: @user.account)
			@event = FactoryGirl.create(:event, account: @user.account, schedulable: @rehearsal)
		end
		
		it "should be able to manage Rehearsal Events" do
			should be_able_to :read, @rehearsal.event
		end
		
		it "should NOT be able to read other types of Events" do
			@event = FactoryGirl.create(:event, account: @user.account)
			should_not be_able_to :read, @event
		end
		
		it "should be able to manage Rehearsals" do
			should be_able_to :manage, Rehearsal
		end
	end
	
	context "Schedule Lecture Demos:" do
		before do
			@user = FactoryGirl.create(:user, :with_role, role_name: 'Schedule Lecture Demos')
			Account.current_id = @user.account_id
			@demo = FactoryGirl.create(:lecture_demo, account: @user.account)
			@event = FactoryGirl.create(:event, account: @user.account, schedulable: @demo)
		end
		
		it "should be able to read Lecture Demo Events" do
			should be_able_to :read, @demo.event
		end
		
		it "should NOT be able to read other types of Events" do
			@other_type = FactoryGirl.create(:costume_fitting, account: @user.account)
			@event = FactoryGirl.create(:event, account: @user.account, schedulable: @other_type)
			should_not be_able_to :read, @event
		end
		
		it "should be able to manage Lecture Demos" do
			should be_able_to :manage, LectureDemo
		end
	end
	
	context "Manage Casts:" do
		before do
			@user = FactoryGirl.create(:user, :with_role, role_name: 'Manage Casts')
			Account.current_id = @user.account_id
		end
		
		it "should be able to read Seasons" do
			should be_able_to :read, Season
		end
		
		it "should be able to read Season Pieces" do
			should be_able_to :read, SeasonPiece
		end
		
		it "should be able to manage unpublished Casts" do
			@sp = FactoryGirl.create(:season_piece, account: @user.account)
			should be_able_to :manage, @sp.casts.build
		end
		
		it "should be able to read published Casts" do
			@sp_published = FactoryGirl.create(:season_piece, :published, account: @user.account)
			should be_able_to :read,  @sp_published.casts.build
		end
		
		it "should NOT be able to create/update/destroy published Casts" do
			@sp_published = FactoryGirl.create(:season_piece, :published, account: @user.account)
			@cast = @sp_published.casts.build
			should_not be_able_to :create, @cast
			should_not be_able_to :update, @cast
			should_not be_able_to :destroy, @cast
		end
		
		it "should be able to manage unpublished Castings" do
			@piece = FactoryGirl.create(:piece, account: @user.account)
			@character = FactoryGirl.create(:character, account: @user.account, piece: @piece)
			@sp = FactoryGirl.create(:season_piece, account: @user.account, piece: @piece)
			@cast = FactoryGirl.create(:cast, season_piece: @sp)
			
			should be_able_to :manage, @cast.castings.first
		end
		
		it "should be able to read published Castings" do
			@piece = FactoryGirl.create(:piece, account: @user.account)
			@character = FactoryGirl.create(:character, account: @user.account, piece: @piece)
			@sp_published = FactoryGirl.create(:season_piece, :published, account: @user.account, piece: @piece)
			@cast = FactoryGirl.create(:cast, season_piece: @sp_published)
			
			should be_able_to :read, @cast.castings.first
		end
		
		it "should NOT be able to create/update/destroy published Castings" do
			@piece = FactoryGirl.create(:piece, account: @user.account)
			@character = FactoryGirl.create(:character, account: @user.account, piece: @piece)
			@sp_published = FactoryGirl.create(:season_piece, :published, account: @user.account, piece: @piece)
			@cast = FactoryGirl.create(:cast, season_piece: @sp_published)
			
			should_not be_able_to :create, @cast.castings.build
			should_not be_able_to :update, @cast.castings.first
			should_not be_able_to :destroy, @cast.castings.first
		end
		
		it "should be able to publish the Casting" do
			should be_able_to :update, :publish_cast
		end
	end
	
	context "Manage Account:" do
		before do
			@user = FactoryGirl.create(:user, :with_role, role_name: 'Manage Account')
			Account.current_id = @user.account_id
		end
		
		context "for Account" do
			it "should be able to read/update their own Account" do
				should be_able_to :read, @user.account
				should be_able_to :update, @user.account
			end
		
			it "should NOT be able to read/update other Accounts" do
				other_account = FactoryGirl.create(:account)
				should_not be_able_to :read, other_account
				should_not be_able_to :update, other_account
			end
		end
		
		context "for Addresses" do
			it "should be able to manage their own Account's Addresses" do
				account = @user.account
				should be_able_to :manage, account.addresses.build
			end
		
			it "should NOT be able to manage other Account's Addresses" do
				other_account = FactoryGirl.create(:account)
				should_not be_able_to :manage, other_account.addresses.build
			end
		end
		
		context "for Phone Numbers" do
			it "should be able to manage their own Account's Phone Numbers" do
				account = @user.account
				should be_able_to :manage, account.phones.build
			end
		
			it "should NOT be able to manage other Account's Phone Numbers" do
				other_account = FactoryGirl.create(:account)
				should_not be_able_to :manage, other_account.phones.build
			end
		end
		
		it "should be able to manage their Payment Method" do
			should be_able_to :manage, :payment
		end
		
		it "should be able to manage their Subscription" do
			should be_able_to :manage, :subscription
		end
	end
	
	context "Administrator:" do
		before do
			@user = FactoryGirl.create(:user, :with_role, role_name: 'Administrator')
			Account.current_id = @user.account_id
		end
		
		pending "All of above"
	end
end
