require 'spec_helper'

describe "Static Pages:" do
	subject { page }
	
  it "home" do
    visit root_path
    click_link 'Home'
  	
  	should have_selector('title', text: 'Scheduler')
	  should have_selector('h1', text: 'Scheduler')
	  
	  should have_link('Sign In', href: login_path)
  end
  
  it "features" do
  	visit root_path
  	click_link 'Features'
  	
		should have_selector('title', text: 'Features')
	  should have_selector('h1', text: 'Features')
  end
  
  it "pricing" do
  	visit root_path
  	click_link 'Pricing & Signup'
  	
		should have_selector('title', text: 'Pricing')
	  should have_selector('h1', text: 'Pricing')
  end
  
  it "contact" do
  	visit root_path
  	click_link 'Contact Us'
  	
		should have_selector('title', text: 'Contact Us')
	  should have_selector('h1', text: 'Contact Us')
  end
  
  context "dashboard" do
  	it "has correct title" do
	  	log_in
	  	visit dashboard_path
	  	
			should have_selector('title', text: 'Dashboard')
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
