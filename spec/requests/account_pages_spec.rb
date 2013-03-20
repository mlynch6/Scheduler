require 'spec_helper'

describe "Account Pages:" do
  subject { page }
	
	context "#new" do	  
	  it "signup with error" do
	  	visit signup_path
	  	click_button "Create Account"
    	
    	should have_selector('title', text: 'Create Account')
    	should have_selector('h1', text: 'Create an Account')
    	should have_selector('div.alert-error')
    	should have_link('Terms of Service')
    	should have_link('Privacy')
    end
    
    describe "signup with valid info" do
    	let(:username) { Faker::Internet.user_name }
    	let(:company) { Faker::Company.name }
    	let(:emp_last_name) { Faker::Name.last_name }
    	before do
    		visit signup_path
    		fill_in "Company", with: company
    		fill_in "Phone #", with: "414-543-1000"
    		select  "(GMT-08:00) Pacific Time (US & Canada)", from: "Time Zone"
    		fill_in "First Name", with: Faker::Name.first_name
    		fill_in "Last Name", with: emp_last_name
    		fill_in "Job Title", with: Faker::Name.title
    		fill_in "Email", with: Faker::Internet.free_email
    		fill_in "Username", with: username
    		fill_in "Password", with: "password"
    		fill_in "Confirm Password", with: "password"
    		click_button "Create Account"
    	end
    	
#    	it "creates an Account" do
#    		expect { click_button "Create Account" }.to change(Account, :count).by(1)
#    	end
    	
    	it "creates the Account" do
    		Account.find_by_name(company).should_not == company
    	end
    	
    	it "creates an Employee" do
    		emp = Employee.unscoped.last
    		emp.last_name.should == emp_last_name
    	end
    	
    	it "creates a User" do
    		User.unscoped.last.role.should == "Administrator"
    	end
    	
    	it "logs in the new user" do
    		should have_selector('title', text: 'Dashboard')
    		should have_link('Sign Out', href: logout_path)
				should have_content(username)
    	end
    	
    	describe "has correct account scope assigned" do
    		let(:new_location) { Faker::Lorem.word }
    		before do
    			visit locations_path
	  			click_link 'New'
					fill_in "Name", with: new_location
					click_button 'Create'
				end

				it "creates a new record" do
					should have_content(new_location)
				end
    	end
    end
	end
	
	context "#show" do
		it "has correct title" do
			log_in
			click_link "Settings"
	  	
	  	should have_selector('title', text: 'Settings')
			should have_selector('h1', text: 'Settings')
		end
		
		it "has Edit Settings links" do
			log_in
			click_link "Settings"
	  	
	  	should have_link('Company Info')
			should have_link('Rehearsal Weeks')
		end
		
		it "has Company Info section" do
			log_in
			click_link "Settings"
	  	
			should have_selector('h2', text: 'Company Info')
			should have_selector('div.label-ui', text: 'Company')
			should have_selector('div.label-ui', text: 'Phone #')
			should have_selector('div.label-ui', text: 'Time Zone')
		end
		
		it "has Rehearsal Weeks section" do
			log_in
			click_link "Settings"
	  	
			should have_selector('h2', text: 'Rehearsal Weeks')
			should have_selector('div.label-ui', text: 'Rehearsal Start')
			should have_selector('div.label-ui', text: 'Rehearsal End')
			should have_selector('div.label-ui', text: 'Max Hours/Week')
			should have_selector('div.label-ui', text: 'Max Hours/Day')
			should have_selector('div.label-ui', text: 'Rehearsal Increments')
			should have_selector('div.label-ui', text: 'Class Break')
		end
	end
	
	context "#edit" do
		it "has correct title" do
			log_in
			click_link "Settings"
			click_link "Company Info"
	  	
	  	should have_selector('title', text: 'Company Info')
			should have_selector('h1', text: 'Company Info')
		end
		
	  it "record with error" do
	  	log_in
			click_link "Settings"
			click_link "Company Info"
	  	fill_in "Company", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-error')
		end
	
		it "with bad record in URL shows current account" do
			pending
			log_in
			visit edit_account_path(0)
	
			should have_selector('title', text: 'Company Info')
			should have_content(current_account.name)
		end
		
		it "record with wrong account shows current account" do
			pending
			wrong_account = FactoryGirl.create(:account)
			log_in
			visit edit_account_path(wrong_account)
	
			should have_selector('title', text: 'Company Info')
			should have_content(current_account.name)
		end
	 
		it "record with valid info saves account" do
			log_in
			new_name = Faker::Lorem.word
			click_link "Settings"
			click_link "Company Info"
			fill_in "Company", with: new_name
    	fill_in "Phone #", with: "414-888-0000"
    	select  "(GMT-10:00) Hawaii", from: "Time Zone"
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Settings')
			
			should have_selector('div.text-ui', text: new_name)
			should have_selector('div.text-ui', text: "414-888-0000")
			should have_selector('div.text-ui', text: "Hawaii")
		end
	end
end
