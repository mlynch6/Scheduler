class SeasonsController < ApplicationController
	def index
  	@seasons = Season.paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def new
		form_setup
		@season = Season.new
	end
	
	def create
		@season = Season.new(params[:season])
		if @season.save
			redirect_to seasons_path, :notice => "Successfully created the season."
		else
			form_setup
			render 'new'
		end
	end
	
	def edit
		@season = Season.find(params[:id])
		@season.start_dt = @season.start_dt.to_s(:default)
		@season.end_dt = @season.end_dt.to_s(:default)
		form_setup
	end
	
	def update
		@season = Season.find(params[:id])
		if @season.update_attributes(params[:season])
			redirect_to seasons_path, :notice => "Successfully updated the season."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		Season.find(params[:id]).destroy
		redirect_to seasons_path, :notice => "Successfully deleted the season."
	end

	private

	#setup for form - dropdowns, etc
	def form_setup
	end
end
