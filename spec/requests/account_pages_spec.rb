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
    	let(:last_name) { Faker::Name.last_name }
    	before do
    		visit signup_path
    		fill_in "Company", with: company
    		fill_in "Phone #", with: "414-543-1000"
    		select  "(GMT-08:00) Pacific Time (US & Canada)", from: "Time zone"
    		fill_in "First Name", with: Faker::Name.first_name
    		fill_in "Last Name", with: last_name
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
#    	
#    	it "creates an Employee" do
#    		expect { click_button "Create Account" }.to change(Employee, :count).by(1)
#    	end
#    	
#    	it "creates a User as Administrator" do
#    		expect { click_button "Create Account" }.to change(User, :count).by(1)
#    		User.last.role.should == "Administrator"
#    	end
    	
    	it "creates Account, Employee, and User & logs in user" do
    		Account.unscoped.last.name.should == company
    		Employee.unscoped.last.last_name.should == last_name
    		User.unscoped.last.role.should == "Administrator"
    		
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
end
