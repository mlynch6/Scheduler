require 'spec_helper'

describe "Authentication" do
	subject { page }
	
	it "Sign In that is invalid gives error" do
  	visit login_path
  	click_button "Sign In"
  	
	  should have_selector('title', text: 'Sign In')
	  should have_selector('h1', text: 'Sign In')
		should have_selector('div.alert-error')
	end
    
	it "Sign In that is valid logs user in" do
		log_in
		
		should have_selector('title', text: 'Dashboard')
		should have_link('Sign Out', href: logout_path)
	end
	
	it "Sign Out logs user out" do
		log_in
		click_link "Sign Out"
		
		should have_link('Sign In')
		should have_content('Logged out')
	end
end