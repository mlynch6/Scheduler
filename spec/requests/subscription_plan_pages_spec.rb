require 'spec_helper'

describe "Subscription Plan Pages:" do
	subject { page }

	context "#index" do
		it "has correct title & table headers" do
			log_in
	  	click_link "Subscription Plans"
	  	
	  	should have_selector('title', text: 'Subscription Plans')
		  should have_selector('h1', text: 'Subscription Plans')
	  	
	    should have_selector('th', text: "Name")
	    should have_selector('th', text: "Amount")
		end
		
		it "without records" do
			log_in
			SubscriptionPlan.delete_all
	  	visit admin_subscription_plans_path
	  	
	    should have_selector('div.alert')
			should_not have_selector('td')
			should_not have_selector('div.pagination')
			
			#Repopulate records so subscription tests do not fail
			2.times { FactoryGirl.create(:subscription_plan) }
		end
	  
		it "lists records" do
			log_in
			4.times { FactoryGirl.create(:subscription_plan) }
			visit admin_subscription_plans_path
	
			SubscriptionPlan.all.each do |plan|
				should have_selector('td', text: plan.name)
				should have_selector('td', text: number_to_currency(plan.amount))
				should have_link('Edit', href: edit_admin_subscription_plan_path(plan))
				should have_link('Delete', href: admin_subscription_plan_path(plan))
	    end
		end
		
		it "has links for Super Administrator" do
			log_in
			FactoryGirl.create(:subscription_plan)
			visit admin_subscription_plans_path
	
			should have_link('Add Subscription Plan')
			should have_link('Edit')
			should have_link('Delete')
		end
	end
	
	context "#new" do
		it "has correct title" do
			log_in
	  	click_link 'Subscription Plans'
	  	click_link 'Add Subscription Plan'
	
			should have_selector('title', text: 'Add Subscription Plan')
			should have_selector('h1', text: 'Add Subscription Plan')
		end
		
		context "with error" do
			it "shows error message" do
				log_in
				visit new_admin_subscription_plan_path
		  	click_button 'Create'
		
				should have_selector('div.alert-error')
			end
			
			it "doesn't create Subscription Plan" do
				log_in
				visit new_admin_subscription_plan_path
		
				expect { click_button 'Create' }.not_to change(SubscriptionPlan, :count)
			end
		end
	
		context "with valid info" do
			it "creates new Subscription Plan" do
				log_in
				visit new_admin_subscription_plan_path
				
		  	new_name = Faker::Lorem.word
		  	new_amount = 10.10
				fill_in "Name", with: new_name
				fill_in "Amount", with: new_amount
				click_button 'Create'

				should have_selector('div.alert-success')
				should have_selector('title', text: 'Subscription Plans')
				should have_content(new_name)
				should have_content(new_amount)
			end
		end
	end

	context "#edit" do
		it "has correct title" do
			log_in
			plan = FactoryGirl.create(:subscription_plan)
	  	click_link "Subscription Plans"
	  	click_link "Edit"
	  	
	  	should have_selector('title', text: 'Edit Subscription Plan')
			should have_selector('h1', text: 'Edit Subscription Plan')
		end
		
	  it "with error shows error message" do
	  	log_in
	  	plan = FactoryGirl.create(:subscription_plan)
	  	visit edit_admin_subscription_plan_path(plan)
	  	
	  	fill_in "Name", with: ""
	  	click_button 'Update'
	
			should have_selector('div.alert-error')
		end
	
		it "with bad record in URL shows 'Record Not Found' error" do
			pending
			log_in
			visit edit_admin_subscription_plan_path(0)
	
			should have_content('Record Not Found')
		end
	 
		it "with valid info" do
			log_in
			plan = FactoryGirl.create(:subscription_plan)
	  	visit edit_admin_subscription_plan_path(plan)
	  	
			new_name = Faker::Lorem.word
			new_amount = 12.12
			fill_in "Name", with: new_name
			fill_in "Amount", with: new_amount
			click_button 'Update'
	
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Subscription Plans')
			should have_content(new_name)
			should have_content(new_amount)
		end
	end

	context "#destroy" do
		it "deletes the record" do
	  	log_in
			plan = FactoryGirl.create(:subscription_plan)
			visit admin_subscription_plans_path
			click_link "delete_#{plan.id}"
			
			should have_selector('div.alert-success')
			should have_selector('title', text: 'Subscription Plans')
			
			should_not have_content(plan.name)
		end
	end
end
