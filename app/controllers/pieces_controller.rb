class PiecesController < ApplicationController
	before_filter :get_resource, :only => [:edit, :update, :destroy, :activate, :inactivate]
	
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
		form_setup
	end
	
	def update
		if @piece.update_attributes(params[:piece])
			redirect_to pieces_path, :notice => "Successfully updated the piece."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		@piece.destroy
		redirect_to pieces_path, :notice => "Successfully deleted the piece."
	end
	
	def activate
		@piece.activate
		redirect_to inactive_pieces_path, :notice => "Successfully activated the piece."
	end
	
	def inactivate
		@piece.inactivate
		redirect_to pieces_path, :notice => "Successfully inactivated the piece."
	end

private
	def get_resource
		@piece = Piece.find(params[:id])
	end
	
	#setup for form - dropdowns, etc
	def form_setup
	end
end
