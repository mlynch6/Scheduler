class AccountsController < ApplicationController
   def new
  	@account = Account.new
  	@addressable = @account
  	address = @account.addresses.build
  	address.addr_type = "Work"
  	employee = @account.employees.build
  	employee.role = "Artistic Director"
  	employee.build_user
  	form_setup
  end

  def create
  	@account = Account.new(params[:account])
  	@addressable = @account
  	employee = @account.employees.first
  	employee.new_registration = true
  	employee.user.new_registration = true
  	if @account.save
  		user = employee.user
  		user.set_admin_role
  		session[:user_id] = user.id
  		redirect_to login_path, :notice => "Congratulations! You have successfully created an account for #{@account.name}." 
  	else
  		form_setup
  		render "new"
  	end
  end
  
  def edit
		@account = Account.find(Account.current_id)
		form_setup
	end
	
	def update
		@account = Account.find(Account.current_id)
		if @account.update_attributes(params[:account])
			redirect_to account_path(@account), :notice => "Successfully updated the Company Information"
		else
			form_setup
			render 'edit'
		end
	end
	
	def show
		@account = Account.joins(:agma_profile).find(Account.current_id)
	end
	
	private

	#setup for form - dropdowns, etc
	def form_setup
	end
end
