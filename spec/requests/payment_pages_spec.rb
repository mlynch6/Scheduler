require 'spec_helper'

describe "Payment Pages:" do
  subject { page }
	
	context "#edit" do
		it "has correct title" do
			log_in
	  		click_link 'Setup'
	  		click_link 'My Subscription'
	  		click_link 'Change Payment Method'
	  	
			should have_title 'Change Payment Method'
			should have_selector 'h1', text: 'Change Payment Method'
		end
		
		it "has correct Navigation" do
			log_in
			visit payments_edit_path
			
			should have_selector 'li.active', text: 'Setup'
			should have_selector 'li.active', text: 'My Subscription'
		end
		
		it "has correct fields on form" do
			log_in
			visit payments_edit_path
			
			should have_field 'Credit Card Number'
	    should have_select 'card_month'
	    should have_select 'card_year'
	    should have_field 'Security Code'
		end
	end
	
	context "#edit", js: true do
		before do
			log_in
			create_stripe_account(current_account)
  		
			visit subscriptions_current_path
			click_link "Change Payment Method"
		end
  	
		after do
			destroy_stripe_account(current_account)
		end
		
		it "can update the credit card" do
			fill_in "Credit Card Number", with: "5105105105105100" #valid testing Mastercard
			select (Date.today.year+1).to_s, from: "card_year"
			fill_in "Security Code", with: "213"
			click_button "Update"
		  
			should have_selector 'div.alert-success'
		  should have_title 'My Subscription'
		end
		
		describe "invalid Payment" do
			it "with invalid credit card number shows error" do
				fill_in "Credit Card Number", with: "4242424242424241"
				select (Date.today.year+1).to_s, from: "card_year"
				fill_in "Security Code", with: "213"
				click_button "Update"
	    	
				should have_selector 'div.alert-danger', text: 'card number is incorrect'
			end
	    
			it "with invalid security code shows error" do
				fill_in "Credit Card Number", with: "4242424242424242"
				select (Date.today.year+1).to_s, from: "card_year"
				fill_in "Security Code", with: "99"
				click_button "Update"
	    	
				should have_selector 'div.alert-danger', text: 'security code is invalid'
	    end
	    
			it "with card declined error" do
				fill_in "Credit Card Number", with: "4000000000000002" #always returns card declined
				select (Date.today.year+1).to_s, from: "card_year"
				fill_in "Security Code", with: "213"
				click_button "Update"
	    	
				should have_selector 'div.alert-danger', text: 'card was declined'
	    end
	  end
	end
end
