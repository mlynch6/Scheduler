class AccountsController < ApplicationController
	load_resource :except => [:new, :create]
	authorize_resource
	
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
	end
	
	def update
		if @account.update_attributes(params[:account])
			redirect_to account_path(@account), :notice => "Successfully updated the Company Information"
		else
			render 'edit'
		end
	end
	
	def show
	end
	
private
	#setup for form - dropdowns, etc
	def form_setup
		@plans = SubscriptionPlan.all.map { |plan| [plan.name_and_amount, plan.id] }
	end
end
