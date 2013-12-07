class SubscriptionsController < ApplicationController
	before_filter :get_resource, :only => [:show, :edit, :update, :destroy]

	def show
		@invoices = @account.list_invoices
		@next_invoice_date = @account.next_invoice_date
		show_stripe_errors
	end
	
	def edit
		form_setup
	end
	
	def update
		@account.current_subscription_plan_id = params[:account][:current_subscription_plan_id]
		
		if @account.edit_subscription_plan
			redirect_to subscriptions_current_path, :notice => "Successfully updated your Subscription"
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		if @account.cancel_subscription
  		redirect_to account_path(@account), :notice => "Your subscription has been canceled."
  	else
	  	show_stripe_errors
	  	redirect_to subscriptions_current_path
	  end
	end
	
private
	def get_resource
		@account = Account.find(Account.current_id)
	end
	
	#setup for form - dropdowns, etc
	def form_setup
		@plans = SubscriptionPlan.all.map { |plan| [plan.name_and_amount, plan.id] }
	end
	
	def show_stripe_errors
		if ! @account.errors.messages[:payment].nil?
			@account.errors.messages[:payment].each do |msg|
				flash[:error] = msg
			end
		end
	end
end
