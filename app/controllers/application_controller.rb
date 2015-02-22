class ApplicationController < ActionController::Base
  protect_from_forgery
	check_authorization
  helper :link
	helper_method :current_user, :current_season
  
	before_filter :https_redirect
	before_filter :miniprofiler
  around_filter :scope_current_account
  around_filter :account_time_zone, if: :current_user
  
	rescue_from CanCan::AccessDenied do |exception|
		flash[:error] = exception.message
		redirect_to root_url
	end
		
private

	def current_user
		@current_user ||= User.unscoped.find(session[:user_id]) if session[:user_id]
	end
	
	def current_season
		@current_season ||= Season.find(session[:current_season_id]) if session[:current_season_id]
		@current_season ||= Season.first
	end
	
	def scope_current_account
		Account.current_id = current_user.account_id if current_user
		yield
	ensure
		Account.current_id = nil
	end
	
	def account_time_zone(&block)
		Time.use_zone(current_user.account.time_zone, &block)
	end
	
	def https_redirect
		if ENV["ENABLE_HTTPS"] == "yes"
			if request.ssl? && !use_https? || !request.ssl? && use_https?
				protocol = request.ssl? ? "http" : "https"
				flash.keep
				redirect_to params: request.query_parameters, protocol: "#{protocol}://", status: :moved_permanently
			end
		end
	end
	
	def use_https?
		true # Override in other controllers
	end
	
	def miniprofiler
		Rack::MiniProfiler.authorize_request if current_user && current_user.superadmin?
	end
end
