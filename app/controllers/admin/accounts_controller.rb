class Admin::AccountsController < ApplicationController
	load_and_authorize_resource

	def index
		@accounts = @accounts.paginate(page: params[:page], per_page: params[:per_page])
	end

	def edit
		form_setup
	end
	
	def update
		@account.accessible = :all if current_user.superadmin?
		if @account.update_attributes(params[:account])
			redirect_to admin_accounts_path, :notice => "Successfully updated the account."
		else
			form_setup
			render 'edit'
		end
	end

	def destroy
		if @account.destroy
			redirect_to admin_accounts_path, :notice => "Successfully deleted the account."
		else
			flash[:error] = "There was an error deleting the account."
			redirect_to admin_accounts_path
		end
	end

private
	#setup for form - dropdowns, etc
	def form_setup
		@plans = SubscriptionPlan.all.map { |plan| [plan.name_and_amount, plan.id] }
	end
end
