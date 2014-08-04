require 'spec_helper'

describe "Payment Pages:" do
  subject { page }
	
	context "#edit" do
		before do
			log_in
			click_link 'Home'
			click_link 'My Account'
			click_link 'Subscription'
			click_link 'Change Payment Method'
		end
		
		it "has correct title" do
			should have_title 'Account | Change Payment Method'
			should have_selector 'h1', text: 'Account'
			should have_selector 'h1 small', text: 'Change Payment Method'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Home'
			should have_selector 'li.active', text: 'My Account'
			should have_selector 'li.active', text: 'Subscription'
		end
		
		it "has correct fields on form" do
			should have_field 'Credit Card #'
	    should have_select 'card_month'
	    should have_select 'card_year'
	    should have_field 'Security Code'
			should have_link 'Cancel', href: subscriptions_current_path
		end
		
		it "has links for Super Admin" do
	  	should have_link 'Overview'
			should have_link 'Subscription'
			
			should have_link 'Change Payment Method'
		end
	end
	
	context "#edit", js: true do
		before do
			log_in
			create_stripe_account(current_account)
			visit payments_edit_path
		end
  	
		after do
			destroy_stripe_account(current_account)
		end
		
		it "can update the credit card" do
			fill_in "Credit Card #", with: "5105105105105100" #valid testing Mastercard
			select (Date.today.year+1).to_s, from: "card_year"
			fill_in "Security Code", with: "213"
			click_button "Update"
		  
			should have_selector 'div.alert-success'
		  should have_title 'Account | Subscription'
		end
		
		describe "invalid Payment" do
			it "with invalid credit card number shows error" do
				fill_in "Credit Card #", with: "4242424242424241"
				select (Date.today.year+1).to_s, from: "card_year"
				fill_in "Security Code", with: "213"
				click_button "Update"
	    	
				should have_selector 'div.alert-danger', text: 'card number is incorrect'
			end
	    
			it "with invalid security code shows error" do
				fill_in "Credit Card #", with: "4242424242424242"
				select (Date.today.year+1).to_s, from: "card_year"
				fill_in "Security Code", with: "99"
				click_button "Update"
	    	
				should have_selector 'div.alert-danger', text: 'security code is invalid'
	    end
	  end
	end
end
