class CastsController < ApplicationController	
	before_filter :get_resource, :only => [:new, :show]
	
	def show
		@cast = Cast.find(params[:id])
		@castings = @cast.castings.joins(:character).order('characters.position ASC')
	end
	
	def new
		if @sp.casts.create
			redirect_to season_path(@sp.season), :notice => "Successfully created the cast."
		else
			flash[:error] = "Cast was not created."
			redirect_to season_path(@sp.season)
		end
	end
	
	def destroy
		@cast = Cast.find(params[:id])
		@season = @cast.season_piece.season
		@cast.destroy
		redirect_to season_path(@season), :notice => "Successfully deleted the cast."
	end
	
	private
		def get_resource
			@sp = SeasonPiece.find(params[:season_piece_id])
		end
end
