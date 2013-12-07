class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :link
  
  before_filter :authorize
  around_filter :scope_current_account
  around_filter :account_time_zone, if: :current_user
  
  delegate :allow?, to: :current_permission
  helper_method :allow?
  
private

	def current_user
		@current_user ||= User.unscoped.find(session[:user_id]) if session[:user_id]
	end
	helper_method :current_user
	
	def scope_current_account
		Account.current_id = current_user.account_id if current_user
		yield
	ensure
		Account.current_id = nil
	end
	
	def account_time_zone(&block)
		Time.use_zone(current_user.employee.account.time_zone, &block)
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
