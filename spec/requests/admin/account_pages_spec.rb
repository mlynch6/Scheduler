require 'spec_helper'

describe "Admin Account Pages:" do
	subject { page }

	context "#index" do
		it "has correct title" do
			log_in
			click_link "Administration"
			click_link "Accounts"

			should have_title 'Accounts'
			should have_selector 'h1', text: 'Accounts'
		end

		it "has correct Navigation" do
			log_in
			visit admin_accounts_path

			should have_selector 'li.active', text: 'Administration'
			should have_selector 'li.active', text: 'Accounts'
		end

		it "without records" do
			pending "Will always have at least 1 account (the one you are logged in under)"
			log_in
			visit admin_accounts_path

			should have_selector 'p', text: 'No accounts found'
			should_not have_selector 'td'
			should_not have_selector 'div.pagination'
		end

		it "lists records" do
			log_in
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

				should have_link 'Edit', href: edit_admin_account_path(account)
				should have_link 'Delete', href: admin_account_path(account)
			end
		end
	end

	# context "#destroy" do
	# 	it "deletes the record" do
	# 		log_in
	# 		account = FactoryGirl.create(:account)
	# 		visit admin_accounts_path
	# 		click_link "delete_#{account.id}"
	# 
	# 		should have_selector 'div.alert-success'
	# 		should have_title 'Accounts'
	# 
	# 		click_link 'All'
	# 		should_not have_content account.name
	# 	end
	# end
end
