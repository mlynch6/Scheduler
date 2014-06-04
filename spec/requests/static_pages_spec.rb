require 'spec_helper'

describe "Static Pages:" do
	subject { page }
	
  context "#home" do
		before do
			visit root_path
			click_link 'Home'
		end
  	
  	it "has correct title" do
	  	should have_title 'Scheduler'
		  should have_selector 'h1', text: 'Scheduler'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Home'
		end
  	
		it "has links for Super Admin" do
			should have_link 'Sign In', href: login_path
		end
  end
	
  context "#features" do
		before do
			visit root_path
			click_link 'Features'
		end
  	
  	it "has correct title" do
	  	should have_title 'Features'
		  should have_selector 'h1', text: 'Features'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Features'
		end
  	
		it "has links for Super Admin" do
			should have_link 'Sign In', href: login_path
		end
  end
	
  context "#pricing" do
		before do
			visit root_path
			click_link 'Pricing & Signup'
		end
  	
  	it "has correct title" do
	  	should have_title 'Pricing'
		  should have_selector 'h1', text: 'Pricing'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Pricing & Signup'
		end
  	
		it "has links for Super Admin" do
			should have_link 'Sign In', href: login_path
		end
  end
	
  context "#contact" do
		before do
			visit root_path
			click_link 'Contact Us'
		end
  	
  	it "has correct title" do
	  	should have_title 'Contact Us'
		  should have_selector 'h1', text: 'Contact Us'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Contact Us'
		end
  	
		it "has links for Super Admin" do
			should have_link 'Sign In', href: login_path
		end
  end
  
  context "#dashboard" do
		before do
	  	log_in
	  	click_link 'Home'
		end
		
  	it "has correct title" do
	  	should have_title 'Dashboard'
		  should have_selector 'h1', text: 'Dashboard'
	  end
  
  	it "has correct Navigation" do
			should have_selector('li.active', text: 'Home')
		end
		
		it "has links for Super Admin" do
			should have_link 'Sign Out', href: logout_path
		end
	end
  
  describe "terms of service" do
  	pending
  end
  
  describe "privacy policy" do
  	pending
  end
end
