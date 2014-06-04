require 'spec_helper'

describe "Admin Account Pages:" do
	subject { page }

	context "#index" do
		before do
			log_in
			click_link "Administration"
			click_link "Accounts"
		end
		
		it "has correct title" do
			should have_title 'Accounts'
			should have_selector 'h1', text: 'Accounts'
		end

		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Administration'
			should have_selector 'li.active', text: 'Accounts'
		end

		it "without records" do
			pending "Will always have at least 1 account (the one you are logged in under)"
			should have_selector 'p', text: 'No accounts found'
			should_not have_selector 'td'
			should_not have_selector 'div.pagination'
		end

		it "lists records" do
			4.times { FactoryGirl.create(:account) }
			visit admin_accounts_path(per_page: 3)

			should have_selector 'th', text: "Id"
			should have_selector 'th', text: "Name"
			should have_selector 'th', text: "Status"
			should have_selector 'th', text: "Customer Id"
			should have_selector 'th', text: "Subscription"
			should have_selector 'div.pagination'

			Account.paginate(page: 1, per_page: 3).each do |account|
				should have_selector 'td', text: account.id
				should have_selector 'td', text: account.name
				should have_selector 'td', text: account.time_zone
				should have_selector 'td', text: account.status
				should have_selector 'td', text: account.stripe_customer_token
				should have_selector 'td', text: account.current_subscription_plan.name

				should have_link account.name, href: edit_admin_account_path(account)
				should have_link 'Delete', href: admin_account_path(account)
			end
		end
	end
	
	context "#edit" do
		before do
			log_in
			@account = FactoryGirl.create(:account)
			click_link 'Administration'
			click_link 'Accounts'
			click_link "edit_#{@account.id}"
		end
		
		it "has correct title" do
			should have_title 'Edit Account'
			should have_selector 'h1', text: 'Accounts'
			should have_selector 'h1 small', text: 'Edit'
		end
	
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Administration'
			should have_selector 'li.active', text: 'Accounts'
		end
		
		it "has correct fields on form" do
			should have_field 'Company'
			should have_select 'Time Zone'
			should have_select 'Status'
			should have_field 'Customer Id'
			should have_select 'Subscription'
			should have_link 'Cancel', href: admin_accounts_path
		end
	
		it "record with error" do
			fill_in 'Company', with: ''
			click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	
		it "record with valid info saves account" do
			fill_in 'Customer Id', with: "New Id"
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Accounts'
	
			should have_content('New Id')
		end
	end

	context "#destroy" do
		before do
			log_in
			@account = FactoryGirl.create(:account)
		end
		
		context "with Stripe customer" do
			before do
				create_stripe_account(@account)
				visit admin_accounts_path
				click_link "delete_#{@account.id}"
			end
			
			it "deletes the record" do
				should have_selector 'div.alert-success'
				should have_title 'Accounts'
		
				should_not have_content @account.stripe_customer_token
				should_not have_selector 'td.mash-col-id', text: @account.id
			end
			
			it "deletes the Stripe customer" do
				customer = Stripe::Customer.retrieve(@account.stripe_customer_token)
				customer.deleted.should be_true
			end
		end
		
		context "without Stripe customer" do
			before do
				visit admin_accounts_path
				click_link "delete_#{@account.id}"
			end
			
			it "deletes the record" do
				should have_selector 'div.alert-success'
				should have_title 'Accounts'
			
				should_not have_selector 'td.mash-col-id', text: @account.id
			end
		end
	end
end
