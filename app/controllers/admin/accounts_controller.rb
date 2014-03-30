class Admin::AccountsController < ApplicationController
	#before_filter :get_resource, :only => [:edit, :update, :destroy]

	def index
		@accounts = Account.paginate(page: params[:page], per_page: params[:per_page])
	end

	# def edit
	# 	form_setup
	# end
	# 
	# def update
	# 	if @account.update_attributes(params[:account])
	# 		redirect_to admin_accounts_path, :notice => "Successfully updated the account."
	# 	else
	# 		form_setup
	# 		render 'edit'
	# 	end
	# end
	# 
	# def destroy
	# 	@account.destroy
	# 	redirect_to admin_accounts_path, :notice => "Successfully deleted the account."
	# end

private
	# def get_resource
	# 	@account = Account.find(params[:id])
	# end
	# 
	# #setup for form - dropdowns, etc
	# def form_setup
	# 	@plans = SubscriptionPlan.all.map { |plan| [plan.name_and_amount, plan.id] }
	# end
end
