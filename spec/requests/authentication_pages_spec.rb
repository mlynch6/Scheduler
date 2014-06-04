require 'spec_helper'

describe "Authentication" do
	subject { page }
	
	context "#new" do
		it "invalid Sign In gives an error" do
	  	visit login_path
	  	click_button 'Sign In'
	  	
		  should have_title 'Sign In'
		  should have_selector 'h1', text: 'Sign In'
			should have_selector 'div.alert-danger'
		end
	    
		it "valid Sign In logs user in" do
			log_in
			
			should have_title 'Dashboard'
			should have_link 'Sign Out', href: logout_path
		end
	end
	
	context "#destroy" do
		before do
			log_in
			click_link 'Sign Out'
		end
		
		it "Sign Out logs user out" do	
			should have_link 'Sign In'
			should have_selector 'div.alert-success'
		end
	end
end