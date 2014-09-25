class Admin::SubscriptionPlansController < ApplicationController
	load_and_authorize_resource
	
	def index
	end
	
	def new
	end
	
	def create
		if @subscription_plan.save
			redirect_to admin_subscription_plans_path, :notice => "Successfully created the subscription plan."
		else
			render 'new'
		end
	end
	
	def edit
	end
	
	def update
		if @subscription_plan.update_attributes(params[:subscription_plan])
			redirect_to admin_subscription_plans_path, :notice => "Successfully updated the subscription plan."
		else
			render 'edit'
		end
	end
	
	def destroy
		@subscription_plan.destroy
		redirect_to admin_subscription_plans_path, :notice => "Successfully deleted the subscription plan."
	end
end
