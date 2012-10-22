class PiecesController < ApplicationController
	def index
		@pieces = Piece.paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def show
		@piece = Piece.find(params[:id])
	end
	
	def new
		form_setup
		@piece = Piece.new
		3.times { @piece.scenes.build }
		3.times { @piece.roles.build }
	end
	
	def create
		@piece = Piece.new(params[:piece])
		if @piece.save
			flash[:success] = "Piece created"
			redirect_to piece_path(@piece)
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
			flash[:success] = "Piece saved"
			redirect_to piece_path(@piece)
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		Piece.find(params[:id]).destroy
		flash[:success] = "Piece deleted"
		redirect_to :action => :index
	end

	private

	#setup for form - dropdowns, etc
	def form_setup
	end
end
