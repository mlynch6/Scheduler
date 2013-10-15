require 'spec_helper'

describe "Subscription Pages:" do
  subject { page }
	
	context "#show" do
		before do
			log_in
			create_stripe_account(current_account)
			visit subscriptions_current_path
		end
		
		after do
			destroy_stripe_account(current_account)
		end
		
		it "has correct title" do
			click_link "My Subscription"
	  	
	  	should have_selector('title', text: 'My Subscription')
			should have_selector('h1', text: 'My Subscription')
		end
		
		it "shows correct data" do
	  	should have_content(current_account.current_subscription_plan.name)
	  	should have_content(current_account.next_invoice_date.strftime('%B %-d, %Y'))
		end
		
		it "has links" do
	  	should have_link('Change Subscription & Payment Method')
		end
		
		it "shows payment history" do
			should have_selector('h2', text: 'Payment History')
			current_account.list_invoices.each do |invoice|
				should have_content(Time.zone.at(invoice.date).to_date)
				should have_content("$0.00")	#Trial Period
			end
		end
		
		it "shows Stripe error" do
			current_account.cancel_subscription
			visit subscriptions_current_path
			
			should have_selector('div.alert-error')
		end
	end
	
	context "#edit" do
		before do
			log_in
			create_stripe_account(current_account)
			visit subscriptions_edit_path
		end
		
		after do
			destroy_stripe_account(current_account)
		end
		
		it "has correct title" do
			click_link "My Subscription"
			click_link "Change Subscription & Payment Method"
	  	
	  	should have_selector('title', text: 'Edit Subscription')
			should have_selector('h1', text: 'Edit Subscription')
		end
		
		it "has links" do
	  	should have_link('My Subscription')
	  	should have_link('Cancel Subscription')
		end
		
		it "can update the credit card" do
			pending
		end
		
		it "does not display Next Payment Date when subscription is canceled" do
	  	should_not have_content((Time.zone.today + 30.days).strftime('%B %-d, %Y'))
		end
	end
	
	context "#destroy" do
		before do
			log_in
			create_stripe_account(current_account)
		end
		
		after do
			destroy_stripe_account(current_account)
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
