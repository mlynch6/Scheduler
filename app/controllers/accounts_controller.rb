class AccountsController < ApplicationController
	before_filter :get_resource, :only => [:edit, :update]
	
   def new
  	@signup_form = SignupForm.new  	
  	form_setup
  end

  def create
  	@signup_form = SignupForm.new
		if @signup_form.submit(params[:account])
			redirect_to login_path, :notice => "Congratulations! You have successfully created an account." 
		else
			form_setup
			render "new"
		end
  end
  
  def edit
		#form_setup
	end
	
	def update
		if @account.update_attributes(params[:account])
			redirect_to account_path(@account), :notice => "Successfully updated the Company Information"
		else
			#form_setup
			render 'edit'
		end
	end
	
	def show
		@account = Account.joins(:agma_contract).find(Account.current_id)
	end
	
private
	def get_resource
		@account = Account.find(Account.current_id)
	end

	#setup for form - dropdowns, etc
	def form_setup
		@plans = SubscriptionPlan.all.map { |plan| [plan.name_and_amount, plan.id] }
	end
end
