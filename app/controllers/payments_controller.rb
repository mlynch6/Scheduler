class PaymentsController < ApplicationController
	before_filter :get_resource, :only => [:edit, :update]

	def edit
		form_setup
	end
	
	def update
		if @account.save_with_payment
			redirect_to subscriptions_current_path, :notice => "Successfully updated your Payment Method"
		else
			form_setup
			render 'edit'
		end
	end
	
private
	def get_resource
		@account = Account.find(Account.current_id)
	end
	
	#setup for form - dropdowns, etc
	def form_setup
	end
end
