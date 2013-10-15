class SubscriptionsController < ApplicationController
	before_filter :get_resource, :only => [:show, :edit, :update, :destroy]

	def show
		@invoices = @account.list_invoices
		@next_invoice_date = @account.next_invoice_date
		
		if !@account.errors.messages[:base].nil?
			@account.errors.messages[:base].each do |msg|
				flash[:error] = msg
			end
		end
	end
	
	def edit
		form_setup
	end
	
	def update
		if @account.update_attributes(params[:account])
			redirect_to account_path(@account), :notice => "Successfully updated the Company Information"
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		@account.cancel_subscription
  	redirect_to account_path(@account), :notice => "Your subscription has been canceled."
  rescue Stripe::InvalidRequestError => e
  	logger.error "Stripe error while canceling subscription for #{@account.id}-#{@account.name}: #{e.message}"
  	flash[:error] = "There was a problem cancelling your subscription."
  	redirect_to subscriptions_current_path
	end
	
	private

	#setup for form - dropdowns, etc
	def form_setup
	end
	
	def get_resource
		@account = Account.find(Account.current_id)
	end
end
