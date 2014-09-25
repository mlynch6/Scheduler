class CastsController < ApplicationController	
	load_and_authorize_resource :season_piece, except: [:destroy]
	load_and_authorize_resource :cast, :through => :season_piece, :shallow => true
	
	def index
		@castings = Casting.includes(:person).joins(:cast, :character).where(casts: {season_piece_id: @season_piece.id}).select("castings.*, casts.name as cast_name, characters.name as character_name").order("characters.position ASC, casts.name ASC").group_by(&:character_name)
		respond_to do |format|
			format.html
			format.pdf do
				pdf = CastingPdf.new(@season_piece, @casts, @castings, view_context)
				send_data pdf.render, filename: "#{@season_piece.piece.name} Casting.pdf", type: "application/pdf"
			end
		end
	end
	
	def show
		@castings = @cast.castings.joins(:character).order('characters.position ASC')
	end
	
	def new
		if @season_piece.casts.create
			redirect_to season_piece_casts_path(@season_piece), :notice => "Successfully created the cast."
		else
			flash[:error] = "Cast was not created."
			redirect_to season_piece_casts_path(@season_piece)
		end
	end
	
	def destroy
		@cast.destroy
		redirect_to season_piece_casts_path(@cast.season_piece), :notice => "Successfully deleted the cast."
	end
end
