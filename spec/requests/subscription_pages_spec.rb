require 'spec_helper'

describe "Subscription Pages:" do
  subject { page }
	
	context "#show" do
		before do
			log_in
			create_stripe_account(current_account)
			click_link 'Home'
			click_link "My Account"
			click_link "Subscription"
		end
		
		after do
			destroy_stripe_account(current_account)
		end
		
		it "has correct title" do
	  	should have_title 'Account | Subscription'
			should have_selector 'h1', text: 'My Account'
			should have_selector 'h1 small', text: 'Subscription'
		end
		
		it "has correct Navigation" do	
			should have_selector 'li.active', text: 'Home'
			should have_selector 'li.active', text: 'My Account'
			should have_selector 'li.active', text: 'Subscription'
		end
		
		it "shows correct data" do
	  	should have_content current_account.current_subscription_plan.name
	  	should have_content current_account.next_invoice_date.strftime('%B %-d, %Y')
		end
		
		it "does not display Next Payment Date when subscription is canceled" do
			current_account.cancel_subscription
			visit subscriptions_current_path
			
	  	should_not have_content (Time.zone.today + 30.days).strftime('%B %-d, %Y')
		end
		
		it "shows payment history" do
			should have_content 'Payment History'
			
			current_account.list_invoices.each do |invoice|
				should have_content Time.zone.at(invoice.date).to_date
				should have_content "$0.00"	#Trial Period
			end
		end
		
		it "shows Stripe error" do
			current_account.cancel_subscription
			visit subscriptions_current_path
			
			should have_selector 'div.alert-danger'
		end
		
		it "has links for Super Admin" do
			should have_link current_account.current_subscription_plan.name
			
	  	should have_link 'Overview'
			should have_link 'Subscription'
			
			should have_link 'Change Payment Method'
		end
	end
	
	context "#edit" do
		before do
			FactoryGirl.create(:subscription_plan, name: 'Dance Company')
			log_in
			create_stripe_account(current_account)
			visit subscriptions_current_path
			click_link current_account.current_subscription_plan.name
		end
		
		after do
			destroy_stripe_account(current_account)
		end
		
		it "has correct title" do
			should have_title 'My Account | Change Subscription'
			should have_selector 'h1', text: 'My Account'
			should have_selector 'h1 small', text: 'Change Subscription'
		end
		
		it "has correct Navigation" do	
			should have_selector 'li.active', text: 'Home'
			should have_selector 'li.active', text: 'My Account'
			should have_selector 'li.active', text: 'Subscription'
		end
		
		it "has correct fields on form" do
			should have_select 'Subscription'
			should have_link 'Cancel', href: subscriptions_current_path
		end
		
		it "has links" do
			should have_link 'Cancel Subscription'
			
	  	should have_link 'Overview'
			should have_link 'Subscription'
		end
		
		it "should change the subscription" do
			select "Dance Company", from: "Subscription"
			click_button "Update"
			
			should have_selector 'div.alert-success'
			should have_title 'My Account | Subscription'
			should have_content 'Dance Company'
		end
	end
	
	context "#destroy" do
		before do
			log_in
			create_stripe_account(current_account)
			visit subscriptions_edit_path
			click_link "Cancel Subscription"
		end
		
		after do
			destroy_stripe_account(current_account)
		end
		
		it "should cancel the subscription" do
			should have_title 'My Account'
			should have_selector 'div.alert-success'
			
			should have_content 'Canceled'
			should have_content 'Canceled On'
		end
	end
end
