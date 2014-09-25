class PiecesController < ApplicationController
	load_and_authorize_resource
	
	def index
		@pieces = @pieces.paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def new
	end
	
	def create
		if @piece.save
			redirect_to pieces_path, :notice => "Successfully created the piece."
		else
			render 'new'
		end
	end
	
	def edit
	end
	
	def update
		if @piece.update_attributes(params[:piece])
			redirect_to pieces_path, :notice => "Successfully updated the piece."
		else
			render 'edit'
		end
	end
	
	def show
	end
	
	def destroy
		@piece.destroy
		redirect_to pieces_path, :notice => "Successfully deleted the piece."
	end
end
