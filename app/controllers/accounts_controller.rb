class AccountsController < ApplicationController
   def new
  	@account = Account.new
  	employee = @account.employees.build
  	employee.build_user
  end

  def create
  	@account = Account.new(params[:account])
  	@account.employees.first.new_registration = true
  	if @account.save
  		user = @account.employees.first.user
  		user.set_admin_role
  		session[:user_id] = user.id
  		session[:session_id] = @account.id
  		redirect_to dashboard_path
  	else
  		render "new"
  	end
  end
end
