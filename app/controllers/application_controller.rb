class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :authorize
  around_filter :scope_current_account
  
  delegate :allow?, to: :current_permission
  helper_method :allow?
  
private

	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end
	helper_method :current_user
	
	def current_account
		@current_account ||= Account.find(session[:account_id]) if session[:account_id]
	end
	helper_method :current_account
	
	def scope_current_account
		Account.current_id = session[:account_id]  if session[:account_id]
		yield
	ensure
		Account.current_id = nil
	end
	
	def current_permission
		@current_permission ||= Permission.new(current_user)
	end
	
	def authorize
		if !current_permission.allow?(params[:controller], params[:action])
			flash[:error] = "Not authorized"
			redirect_to root_url
		end
	end
end
