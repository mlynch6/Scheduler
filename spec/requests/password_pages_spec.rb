require 'spec_helper'

describe "Password Pages:" do
	subject { page }
	
	context "#new" do
		before do
			log_in
			click_link 'Change Password'
		end
		
		it "has correct title" do
			should have_title "Change Password"
		  should have_selector 'h1', text: "Change Password"
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Home'
		end
		
		it "has correct fields on form" do
	  	should have_field 'Current Password'
			should have_field 'New Password'
			should have_field 'Confirm Password'
			should have_link 'Cancel', href: dashboard_path
		end
		
		it "reports error when Current Password is incorrect" do
			fill_in "Current Password", :with => "foobar"
			click_button "Update Password"
			
			should have_selector 'div.alert-danger'
		end
		
		it "reports error when Confirm New Password is incorrect" do
			fill_in "Current Password", :with => "password"
			fill_in "New Password", :with => "foobar"
			fill_in "Confirm Password", :with => "invalid"
			click_button "Update Password"
			
			should have_selector 'div.alert-danger'
		end
		
		it "updates the user password when current password & confirmation matches" do
			fill_in "Current Password", :with => current_user.password
			fill_in "New Password", :with => "foobar"
			fill_in "Confirm Password", :with => "foobar"
			click_button "Update Password"
			
			should have_title current_user.person.full_name
			should have_selector 'div.alert-success', text: 'Password has been changed.'
			
			click_link 'Sign Out'
			click_link 'Sign In'
			fill_in "Username", :with => current_user.username
			fill_in "Password", :with => "foobar"
			click_button 'Sign In'
			
			should have_title 'Dashboard'
		end
	end
end
