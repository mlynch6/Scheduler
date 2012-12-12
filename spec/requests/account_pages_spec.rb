require 'spec_helper'

describe "Account Pages:" do
  subject { page }
	
	describe "new" do
		let(:submit) { "Create Account" }
		before do
  		visit signup_path
  	end
		
		context "page" do
	    it { should have_selector('title', text: 'Create Account') }
	    it { should have_selector('h1', text: 'Create an Account') }
	    describe "Terms of Service link" do
	    	pending
	    end
	    describe "Privacy link" do
	    	pending
	    end
	  end
	  
	  context "(Invalid)" do
	  	before { click_button submit }
    	
    	describe "shows error message" do
    		it { should have_selector('div.alert-error') }
    	end
    end
    
    context "(Valid)" do
    	before do
    		fill_in "Company", with: Faker::Company.name
    		fill_in "Phone #", with: "414-543-1000"
    		select  "(GMT-08:00) Pacific Time (US & Canada)", from: "Time zone"
    		fill_in "First Name", with: Faker::Name.first_name
    		fill_in "Last Name", with: Faker::Name.last_name
    		fill_in "Job Title", with: Faker::Name.title
    		fill_in "Email", with: Faker::Internet.free_email
    		fill_in "Phone #", with: "414-564-7650"
    		fill_in "Username", with: Faker::Internet.user_name
    		fill_in "Password", with: "Password"
    		fill_in "Confirm Password", with: "Password"
    	end
    	
    	it "creates an Account" do
    		expect { click_button submit }.to change(Account, :count).by(1)
    	end
    	
    	it "creates an Employee" do
    		expect { click_button submit }.to change(Employee, :count).by(1)
    	end
    	
    	it "creates a User as Administrator" do
    		expect { click_button submit }.to change(User, :count).by(1)
    		User.last.role.should == "Administrator"
    	end
    	
    	it "logs in user" do
    		click_button submit
    		should have_selector('title', text: 'Dashboard')
    		should have_link('Sign Out', href: logout_path)
    	end
    end
	end
end
