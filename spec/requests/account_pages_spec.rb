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
    	before do
    		visit signup_path
    		fill_in "Company", with: Faker::Company.name
    		fill_in "Phone #", with: "414-543-1000"
    		select  "(GMT-08:00) Pacific Time (US & Canada)", from: "Time zone"
    		fill_in "First Name", with: Faker::Name.first_name
    		fill_in "Last Name", with: Faker::Name.last_name
    		fill_in "Job Title", with: Faker::Name.title
    		fill_in "Email", with: Faker::Internet.free_email
    		fill_in "Username", with: username
    		fill_in "Password", with: "password"
    		fill_in "Confirm Password", with: "password"
    	end
    	
    	it "creates an Account" do
    		expect { click_button "Create Account" }.to change(Account, :count).by(1)
    	end
    	
    	it "creates an Employee" do
    		expect { click_button "Create Account" }.to change(Employee, :count).by(1)
    	end
    	
    	it "creates a User as Administrator" do
    		expect { click_button "Create Account" }.to change(User, :count).by(1)
    		User.last.role.should == "Administrator"
    	end
    	
    	it "logs in user" do
    		click_button "Create Account"
    		
    		should have_selector('title', text: 'Dashboard')
    		should have_link('Sign Out', href: logout_path)
				should have_content(username)
    	end
    	
    	describe "should be able to create record tied to account" do
    		before do
    			click_button "Create Account"
    			visit locations_path
	  			click_link 'New'
					fill_in "Name", with: Faker::Lorem.word
					click_button 'Create'
				end

				it "creates a new record" do
					expect { click_button 'Create' }.to change(Location, :count).by(1)
				end
    	end
    end
	end
end
