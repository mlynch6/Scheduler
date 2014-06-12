class CastsController < ApplicationController	
	before_filter :get_resource, :only => [:new, :show]
	
	def index
		@sp = SeasonPiece.find(params[:season_piece_id])
		@casts = @sp.casts
		@castings = Casting.includes(:person).joins(:cast, :character).where(casts: {season_piece_id: @sp.id}).select("castings.*, casts.name as cast_name, characters.name as character_name").order("characters.position ASC, casts.name ASC").group_by(&:character_name)
		respond_to do |format|
			format.html
			format.pdf do
				pdf = CastingPdf.new(@sp, @casts, @castings, view_context)
				send_data pdf.render, filename: "#{@sp.piece.name} Casting.pdf", type: "application/pdf"
			end
		end
	end
	
	def show
		@cast = Cast.find(params[:id])
		@castings = @cast.castings.joins(:character).order('characters.position ASC')
	end
	
	def new
		if @sp.casts.create
			redirect_to season_piece_casts_path(@sp), :notice => "Successfully created the cast."
		else
			flash[:error] = "Cast was not created."
			redirect_to season_piece_casts_path(@sp)
		end
	end
	
	def destroy
		@cast = Cast.find(params[:id])
		@season = @cast.season_piece.season
		@cast.destroy
		redirect_to season_piece_casts_path(@cast.season_piece), :notice => "Successfully deleted the cast."
	end
	
	private
		def get_resource
			@sp = SeasonPiece.find(params[:season_piece_id])
		end
end
