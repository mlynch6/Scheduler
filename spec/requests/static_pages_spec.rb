require 'spec_helper'

describe "Static Pages:" do
	subject { page }
	
  describe "home" do
    before(:each) do
  		visit root_path
  	end
  	
		context "page" do
	    it { should have_selector('title', text: 'Scheduler') }
	    it { should have_selector('h1', text: 'Scheduler') }
	  end
	  
	  describe "has Guest menu" do
	    it "with a 'Home' link" do
		   	should have_link('Home', href: root_path)
		  end
		    
		  it "with a 'Features' link" do
		  	should have_link('Features', href: features_path)
		  end
		    
		  it "with a 'Pricing & Signup' link" do
		  	should have_link('Pricing & Signup', href: pricing_path)
		  end
		    
		  it "with a 'Contact Us' link" do
		    should have_link('Contact Us', href: contact_path)
		  end
		    
		  it "with a 'Sign In' link" do
		    should have_link('Sign In', href: login_path)
		   end
    end
	  
	  describe "content of page" do
	  	pending
	  end
  end
  
  describe "features" do
  	before(:each) do
  		visit features_path
  	end
  	
		context "page" do
	    it { should have_selector('title', text: 'Features') }
	    it { should have_selector('h1', text: 'Features') }
	  end
	  
	  describe "content of page" do
	  	pending
	  end
  end
  
  describe "pricing" do
  	before(:each) do
  		visit pricing_path
  	end
  	
		context "page" do
	    it { should have_selector('title', text: 'Pricing') }
	    it { should have_selector('h1', text: 'Pricing') }
	  end
	  
	  describe "content of page" do
	  	pending
	  end
  end
  
  describe "contact" do
  	before(:each) do
  		visit contact_path
  	end
  	
		context "page" do
	    it { should have_selector('title', text: 'Contact Us') }
	    it { should have_selector('h1', text: 'Contact Us') }
	  end
	  
	  describe "content of page" do
	  	pending
	  end
  end
  
  describe "dashboard" do
  	before(:each) do
  		visit dashboard_path
  	end
  	
		context "page" do
	    it { should have_selector('title', text: 'Dashboard') }
	    it { should have_selector('h1', text: 'Dashboard') }
	  end
	  
	  describe "content of page" do
	  	pending
	  end
  end
  
  describe "terms of service" do
  	pending
  end
  
  describe "privacy policy" do
  	pending
  end
end
