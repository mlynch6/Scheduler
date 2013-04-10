class SessionsController < ApplicationController
	def new
	end
	
	def create
		user = User.unscoped.find_by_username((params[:username]).downcase)
		if user && user.authenticate(params[:password])
			session[:user_id] = user.id
			redirect_to dashboard_path
		else
			flash[:error] = "Username or password is invalid"
			render "new"
		end
	end
	
	def destroy
		session[:user_id] = nil
		redirect_to root_url, :notice => "You have been successfully signed off."
	end
end
