require 'spec_helper'

describe "Subscription Pages:" do
  subject { page }
	
	context "#show" do
		it "has correct title" do
			log_in
			click_link "My Subscription"
	  	
	  	should have_selector('title', text: 'My Subscription')
			should have_selector('h1', text: 'My Subscription')
		end
		
		it "has links" do
			log_in
			visit subscriptions_current_path
	  	
	  	should have_link('Change Subscription & Payment Method')
		end
		
		it "displays correct data" do
			log_in
			visit subscriptions_current_path
	  	
			pending
		end
		
		it "has payment history shown" do
			log_in
			visit subscriptions_current_path

			should have_selector('h2', text: 'Payment History')
		end
	end
	
	context "#edit" do
		it "has correct title" do
			log_in
			click_link "My Subscription"
			click_link "Change Subscription & Payment Method"
	  	
	  	should have_selector('title', text: 'Edit Subscription')
			should have_selector('h1', text: 'Edit Subscription')
		end
		
		it "has links" do
			log_in
			visit subscriptions_edit_path
	  	
	  	should have_link('My Subscription')
	  	should have_link('Cancel Subscription')
		end
		
		it "can update the credit card" do
			log_in
			visit subscriptions_edit_path

			pending
		end
	end
	
	context "#destroy" do
		before do
			log_in
			create_stripe_account
		end
		
		after do
			destroy_stripe_account
		end
		
		it "should cancel the subscription" do
			visit subscriptions_edit_path
			click_link "Cancel Subscription"
			
			should have_selector('title', text: 'Company Information')
			should have_selector('div.alert-success')
			
			should have_content('Canceled')
			should have_content('Canceled On')
		end
	end
end
