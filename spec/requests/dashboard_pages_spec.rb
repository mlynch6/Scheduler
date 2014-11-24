require 'spec_helper'

describe "Dashboard Pages:" do
	subject { page }
  
  context "#show" do
		before do
	  	log_in
	  	click_link 'Home'
			click_link 'Dashboard'
		end
		
  	it "has correct title" do
	  	should have_title 'Dashboard'
		  should have_selector 'h1', text: 'Dashboard'
	  end
  
  	it "has correct Navigation" do
			should have_selector 'li.active', text: 'Home'
			should have_selector 'li.active', text: 'Dashboard'
		end
		
		it "has links for Super Admin" do
			should have_link 'Sign Out', href: logout_path
		end
	end
end
