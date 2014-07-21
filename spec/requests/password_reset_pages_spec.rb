require 'spec_helper'

describe "Password Reset Pages:" do
	subject { page }
	
	context "#index" do
		before do
			@user = FactoryGirl.create(:user)
			@person = @user.person
			visit login_path
			click_link 'Forgot password'
      fill_in 'Email', with: @person.email
			click_button 'Reset Password'
		end
		
		it "has correct title" do
			should have_title "Password Reset Instructions Sent"
		  should have_selector 'h1', text: "Password Reset Instructions Sent"
		end
		
		it "has message in content" do
	  	should have_selector 'p', text: 'An email has been sent with instructions on how to reset your password.'
		end
	end
	
  context "#new" do
		before do
			@person = FactoryGirl.create(:person, :complete_record)
			@user = FactoryGirl.create(:user, account: @person.account, person: @person)
			visit login_path
			click_link 'Forgot password'
		end
		
		it "has correct title" do
			should have_title "Reset Your Password"
		  should have_selector 'h1', text: "Reset Your Password"
		end
		
		it "has correct fields on form" do
	  	should have_field 'Email'
			should have_link 'Cancel', href: login_path
		end
		
    it "emails user when requesting password reset" do
      fill_in 'Email', with: @person.email
			click_button 'Reset Password'
			
			should have_title 'Password Reset Instructions Sent'
			last_email.to.should include(@person.email)
    end
		
		it "does not email invalid user when requesting password reset" do
			fill_in "Email", :with => "nobody@example.com"
			click_button "Reset Password"
			
			should have_title 'Password Reset Instructions Sent'
			last_email.should be_nil
		end
  end
	
	context "#edit" do
		before do
			@person = FactoryGirl.create(:person, :complete_record)
			@user = FactoryGirl.create(:user,
					account: @person.account,
					person: @person,
					password_reset_token: "something", 
					password_reset_sent_at: 3.hours.ago)
			visit edit_password_reset_path(@user.password_reset_token)
		end
		
		it "has correct title" do
			should have_title "Reset Your Password"
		  should have_selector 'h1', text: "Reset Your Password"
		end
		
		it "has correct fields on form" do
	  	should have_field 'Password'
			should have_field 'Confirm Password'
			should have_link 'Cancel', href: login_path
		end
		
		it "reports error when password confirmation does not match" do
			fill_in "Password", :with => "foobar"
			click_button "Update Password"
			
			should have_selector 'div.alert-danger'
		end
		
		it "updates the user password when confirmation matches" do
			fill_in "Password", :with => "foobar"
			fill_in "Confirm Password", :with => "foobar"
			click_button "Update Password"
			
			should have_title 'Sign In'
			should have_selector 'div.alert-success', text: 'Password has been changed.'
		end

		it "reports when password token has expired" do
			@user.update_attribute(:password_reset_sent_at, 5.hours.ago)
			visit edit_password_reset_path(@user.password_reset_token)
			
			fill_in "Password", :with => "foobar"
			fill_in "Confirm Password", :with => "foobar"
			click_button "Update Password"
			
			should have_title 'Reset Your Password'
			should have_selector 'div.alert-danger', text: 'Password reset has expired.'
		end

		it "raises record not found when password token is invalid" do
			lambda {
				visit edit_password_reset_path("invalid")
			}.should raise_exception(ActiveRecord::RecordNotFound)
		end
	end
end
