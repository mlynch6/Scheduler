class PiecesController < ApplicationController
	def index
		@pieces = Piece.active.paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def inactive
		@pieces = Piece.inactive.paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def new
		form_setup
		@piece = Piece.new
	end
	
	def create
		@piece = Piece.new(params[:piece])
		if @piece.save
			redirect_to pieces_path, :notice => "Successfully created the piece."
		else
			form_setup
			render 'new'
		end
	end
	
	def edit
		@piece = Piece.find(params[:id])
		form_setup
	end
	
	def update
		@piece = Piece.find(params[:id])
		if @piece.update_attributes(params[:piece])
			redirect_to pieces_path, :notice => "Successfully updated the piece."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		Piece.find(params[:id]).destroy
		redirect_to pieces_path, :notice => "Successfully deleted the piece."
	end
	
	def activate
		Piece.find(params[:id]).activate
		redirect_to inactive_pieces_path, :notice => "Successfully activated the piece."
	end
	
	def inactivate
		Piece.find(params[:id]).inactivate
		redirect_to pieces_path, :notice => "Successfully inactivated the piece."
	end

	private

	#setup for form - dropdowns, etc
	def form_setup
	end
end
