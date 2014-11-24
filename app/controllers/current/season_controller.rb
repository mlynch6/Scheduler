class Current::SeasonController < ApplicationController
	def new
		authorize! :new, :current_season
	end
	
	def create
		authorize! :create, :current_season
		session[:current_season_id] = params[:season_id]
		redirect_to dashboard_path, :notice => "The current season is now: #{current_season.name}."
	end
end
