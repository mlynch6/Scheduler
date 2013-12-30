class Admin::SubscriptionPlansController < ApplicationController
	before_filter :get_resource, :only => [:edit, :update, :destroy]
	
	def index
		@plans = SubscriptionPlan.all
	end
	
	def new
		form_setup
		@plan = SubscriptionPlan.new
	end
	
	def create
		@plan = SubscriptionPlan.new(params[:subscription_plan])
		if @plan.save
			redirect_to admin_subscription_plans_path, :notice => "Successfully created the subscription plan."
		else
			form_setup
			render 'new'
		end
	end
	
	def edit
		form_setup
	end
	
	def update
		if @plan.update_attributes(params[:subscription_plan])
			redirect_to admin_subscription_plans_path, :notice => "Successfully updated the subscription plan."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		@plan.destroy
		redirect_to admin_subscription_plans_path, :notice => "Successfully deleted the subscription plan."
	end
	
private
	def get_resource
		@plan = SubscriptionPlan.find(params[:id])
	end
	
	#setup for form - dropdowns, etc
	def form_setup
	end
end
