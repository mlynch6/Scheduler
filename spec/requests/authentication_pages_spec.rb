require 'spec_helper'

describe "Authentication" do
	subject { page }
	
	describe "Sign In" do
		before do
  		visit login_path
  	end
		
		context "page" do
	    it { should have_selector('title', text: 'Sign In') }
	    it { should have_selector('h1', text: 'Sign In') }
	  end
	  
	  it "(Invalid) shows error message" do
	  	click_button "Sign In"
    	should have_selector('div.alert-error')
    end
    
    it "(Valid) logs in user" do
    	log_in
    	should have_selector('title', text: 'Dashboard')
		  should have_link('Sign Out', href: logout_path)
    end
	end
	
	describe "Sign Out" do
		it "logs out user" do
			log_in
			click_link "Sign Out"
		  should have_link('Sign In')
		  should have_content('Logged out')
    end
	end
end