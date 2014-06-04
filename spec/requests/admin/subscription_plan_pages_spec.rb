require 'spec_helper'

describe "Subscription Plan Pages:" do
	subject { page }

	context "#index" do
		before do
			log_in
			click_link "Administration"
	  	click_link "Subscription Plans"
		end
		
		it "has correct title" do
			should have_title 'Subscription Plans'
		  should have_selector 'h1', text: 'Subscription Plans'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Administration'
			should have_selector 'li.active', text: 'Subscription Plans'
		end
		
		it "without records" do
			SubscriptionPlan.delete_all
	  	visit admin_subscription_plans_path
	  	
	    should have_selector 'p', text: 'To begin'
			should_not have_selector 'td'
			should_not have_selector 'div.pagination'
			
			#Repopulate records so subscription tests do not fail
			2.times { FactoryGirl.create(:subscription_plan) }
		end
	  
		it "lists records" do
			4.times { FactoryGirl.create(:subscription_plan) }
			visit admin_subscription_plans_path
	
			should have_selector 'th', text: "Name"
	    should have_selector 'th', text: "Amount"
	
			SubscriptionPlan.all.each do |plan|
				should have_selector 'td', text: plan.name
				should have_selector 'td', text: number_to_currency(plan.amount)
				should have_link plan.name, href: edit_admin_subscription_plan_path(plan)
				should have_link 'Delete', href: admin_subscription_plan_path(plan)
	    end
		end
		
		it "has links for Super Administrator" do
			plan = FactoryGirl.create(:subscription_plan)
			visit admin_subscription_plans_path
	
			should have_link 'Add Subscription Plan'
			should have_link plan.name
			should have_link 'Delete'
		end
	end
	
	context "#new" do
		before do
			log_in
			click_link 'Administration'
	  	click_link 'Subscription Plans'
	  	click_link 'Add Subscription Plan'
		end
		
		it "has correct title" do
			should have_title 'Add Subscription Plan'
			should have_selector 'h1', text: 'Subscription Plans'
			should have_selector 'h1 small', text: 'New'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Administration'
			should have_selector 'li.active', text: 'Subscription Plans'
		end
		
		it "has correct fields on form" do
			should have_field 'Name'
	    should have_field 'Amount'
			should have_link 'Cancel', href: admin_subscription_plans_path
		end
		
		context "with error" do
			it "shows error message" do
		  	click_button 'Create'
		
				should have_selector 'div.alert-danger'
			end
			
			it "doesn't create Subscription Plan" do
				expect { click_button 'Create' }.not_to change(SubscriptionPlan, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Subscription Plan" do
		  	new_name = Faker::Lorem.word
		  	new_amount = 10.10
				fill_in "Name", with: new_name
				fill_in "Amount", with: new_amount
				click_button 'Create'

				should have_selector 'div.alert-success'
				should have_title 'Subscription Plans'
				should have_content new_name
				should have_content new_amount
			end
		end
	end

	context "#edit" do
		before do
			log_in
			plan = FactoryGirl.create(:subscription_plan)
			click_link 'Administration'
	  	click_link "Subscription Plans"
	  	click_link plan.name
		end
		
		it "has correct title" do
	  	should have_title 'Edit Subscription Plan'
			should have_selector 'h1', text: 'Subscription Plans'
			should have_selector 'h1 small', text: 'Edit'
		end
		
		it "has correct Navigation" do
			should have_selector 'li.active', text: 'Administration'
			should have_selector 'li.active', text: 'Subscription Plans'
		end
		
		it "has correct fields on form" do
			should have_field 'Name'
	    should have_field 'Amount'
			should have_link 'Cancel', href: admin_subscription_plans_path
		end
		
	  it "with error shows error message" do
	  	fill_in "Name", with: ""
	  	click_button 'Update'
	
			should have_selector 'div.alert-danger'
		end
	 
		it "with valid info" do
			new_name = Faker::Lorem.word
			new_amount = 12.12
			fill_in "Name", with: new_name
			fill_in "Amount", with: new_amount
			click_button 'Update'
	
			should have_selector 'div.alert-success'
			should have_title 'Subscription Plans'
			should have_content new_name 
			should have_content new_amount
		end
	end

	context "#destroy" do
		before do
	  	log_in
			@plan = FactoryGirl.create(:subscription_plan)
			visit admin_subscription_plans_path
			click_link "delete_#{@plan.id}"
		end
		
		it "deletes the record" do
			should have_selector('div.alert-success')
			should have_title 'Subscription Plans'
			
			should_not have_content @plan.name
		end
	end
end
