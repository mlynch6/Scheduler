class SessionsController < ApplicationController
	def new
	end
	
	def create
		user = User.find_by_username((params[:username]).downcase)
		if user && user.authenticate(params[:password])
			session[:user_id] = user.id
			session[:account_id] = user.employee.account_id
			flash[:success] = "Logged in!"
			redirect_to dashboard_path
		else
			flash[:error] = "Username or password is invalid"
			render "new"
		end
	end
	
	def destroy
		session[:user_id] = nil
		session[:account_id] = nil
		flash[:success] = "Logged out!"
		redirect_to root_url
	end
end
