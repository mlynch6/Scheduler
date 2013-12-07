class AccountsController < ApplicationController
	before_filter :get_resource, :only => [:edit, :update]
	
   def new
  	@account = Account.new
  	
  	@addressable = @account
  	@address = @account.addresses.build
  	@address.addr_type = "Work"
  	
  	@phoneable = @account
  	@phone = @account.phones.build
  	@phone.phone_type = "Work"
  	@phone.primary = true
  	
  	@employee = @account.employees.build
  	@employee.new_registration = true
  	@employee.role = "Artistic Director"
  	
  	@user = @employee.build_user
  	@user.new_registration = true
  	
  	form_setup
  end

  def create
  	@account = Account.new(params[:account])
  	
  	@addressable = @account
  	@address = @account.addresses.first
  	
  	@phoneable = @account
  	@phone = @account.phones.first
  	
  	@employee = @account.employees.first
  	@employee.new_registration = true
  	
  	@user = @employee.user
  	@user.account = @account
  	@user.new_registration = true
  	
  	if @account.save_with_payment
  		@user.set_admin_role
  		redirect_to login_path, :notice => "Congratulations! You have successfully created an account for #{@account.name}." 
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
		@account = Account.joins(:agma_profile).find(Account.current_id)
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
