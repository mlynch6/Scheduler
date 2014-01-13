class PiecesController < ApplicationController
	before_filter :get_resource, :only => [:edit, :update, :show, :destroy]
	
	def index
		@pieces = Piece.paginate(page: params[:page], per_page: params[:per_page])
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
	
	def show
	end
	
	def destroy
		@piece.destroy
		redirect_to pieces_path, :notice => "Successfully deleted the piece."
	end

private
	def get_resource
		@piece = Piece.find(params[:id])
	end
	
	#setup for form - dropdowns, etc
	def form_setup
	end
end
