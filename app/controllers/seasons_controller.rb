class SeasonsController < ApplicationController
	before_filter :get_resource, :only => [:show, :edit, :update, :destroy]
	
	def index
  	@seasons = Season.paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def show
  	@season_pieces = @season.season_pieces.includes(:piece, :casts)
	end
	
	def new
		@season = Season.new
		form_setup(@season)
	end
	
	def create
		@season = Season.new(params[:season])
		if @season.save
			redirect_to seasons_path, :notice => "Successfully created the season."
		else
			form_setup(@season)
			render 'new'
		end
	end
	
	def edit
		@season.start_dt = @season.start_dt.to_s(:default)
		@season.end_dt = @season.end_dt.to_s(:default)
		form_setup(@season)
	end
	
	def update
		if @season.update_attributes(params[:season])
			redirect_to seasons_path, :notice => "Successfully updated the season."
		else
			form_setup(@season)
			render 'edit'
		end
	end
	
	def destroy
		@season.destroy
		redirect_to seasons_path, :notice => "Successfully deleted the season."
	end

private
	def get_resource
		@season = Season.find(params[:id])
	end
	
	#setup for form - dropdowns, etc
	def form_setup(season)
		@pieces = Piece.all.map { |piece| [piece.name, piece.id] }
	end
end
