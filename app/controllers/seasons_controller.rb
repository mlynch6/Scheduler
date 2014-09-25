class SeasonsController < ApplicationController
	load_and_authorize_resource
	
	def index
  	@seasons = @seasons.paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def show
  	@season_pieces = @season.season_pieces.includes(:piece, :casts)
	end
	
	def new
		form_setup
	end
	
	def create
		if @season.save
			redirect_to seasons_path, :notice => "Successfully created the season."
		else
			form_setup
			render 'new'
		end
	end
	
	def edit
		@season.start_dt = @season.start_dt.to_s(:default)
		@season.end_dt = @season.end_dt.to_s(:default)
		form_setup
	end
	
	def update
		if @season.update_attributes(params[:season])
			redirect_to seasons_path, :notice => "Successfully updated the season."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		@season.destroy
		redirect_to seasons_path, :notice => "Successfully deleted the season."
	end

private
	#setup for form - dropdowns, etc
	def form_setup
		@pieces = Piece.all.map { |piece| [piece.name, piece.id] }
	end
end
