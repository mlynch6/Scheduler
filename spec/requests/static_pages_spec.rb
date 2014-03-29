require 'spec_helper'

describe "Static Pages:" do
	subject { page }
	
  it "home" do
    visit root_path
    click_link 'Home'
  	
  	has_title?('Scheduler').should be_true
	  should have_selector('h1', text: 'Scheduler')
	  
	  should have_link('Sign In', href: login_path)
  end
  
  it "features" do
  	visit root_path
  	click_link 'Features'
  	
		has_title?('Features').should be_true
	  should have_selector('h1', text: 'Features')
  end
  
  it "pricing" do
  	visit root_path
  	click_link 'Pricing & Signup'
  	
		has_title?('Pricing').should be_true
	  should have_selector('h1', text: 'Pricing')
  end
  
  it "contact" do
  	visit root_path
  	click_link 'Contact Us'
  	
		has_title?('Contact Us').should be_true
	  should have_selector('h1', text: 'Contact Us')
  end
  
  context "dashboard" do
  	it "has correct title" do
	  	log_in
	  	visit dashboard_path
	  	
			has_title?('Dashboard').should be_true
		  should have_selector('h1', text: 'Dashboard')
	  end
  
  	it "has correct Navigation" do
  		log_in
	  	visit dashboard_path
	  	
			should have_selector('li.active', text: 'Home')
		end
	end
  
  describe "terms of service" do
  	pending
  end
  
  describe "privacy policy" do
  	pending
  end
end
