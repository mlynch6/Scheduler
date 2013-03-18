class AccountsController < ApplicationController
   def new
  	@account = Account.new
  	employee = @account.employees.build
  	employee.build_user
  	form_setup
  end

  def create
  	@account = Account.new(params[:account])
  	@account.employees.first.new_registration = true
  	if @account.save
  		user = @account.employees.first.user
  		user.set_admin_role
  		session[:user_id] = user.id
  		redirect_to dashboard_path
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
			flash[:success] = "Company Info saved"
			redirect_to edit_account_path(@account)
		else
			form_setup
			render 'edit'
		end
	end
	
	private

	#setup for form - dropdowns, etc
	def form_setup
	end
end
