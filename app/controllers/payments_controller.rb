class PaymentsController < ApplicationController
	authorize_resource :class => false
	before_filter :get_resource, :only => [:edit, :update]

	def edit
	end
	
	def update
		if @account.save_with_payment
			redirect_to subscriptions_current_path, :notice => "Successfully updated your Payment Method"
		else
			render 'edit'
		end
	end
	
private
	def get_resource
		@account = Account.find(Account.current_id)
	end
end
