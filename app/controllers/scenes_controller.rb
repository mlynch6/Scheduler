class ScenesController < ApplicationController
	def index
		@piece = Piece.find(params[:piece_id])
		@scenes = @piece.scenes.paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def show
		@scene = Scene.find(params[:id])
	end
	
	def new
		form_setup
		@piece = Piece.find(params[:piece_id])
		@scene = @piece.scenes.build
	end
	
	def create
		@piece = Piece.find(params[:piece_id])
		@scene = @piece.scenes.build(params[:scene])
		
		if @scene.save
			flash[:success] = "Scene created"
			redirect_to piece_scenes_url(@piece)
		else
			form_setup
			render 'new'
		end
	end
	
	def edit
		@scene = Scene.includes(:piece).find(params[:id])
		@piece = @scene.piece
		form_setup
	end
	
	def update
		@scene = Scene.includes(:piece).find(params[:id])
		
		if @scene.update_attributes(params[:scene])
			flash[:success] = "Scene saved"
			redirect_to piece_scenes_url(@scene.piece)
		else
			form_setup
			@piece = @scene.piece
			render 'edit'
		end
	end
	
	def destroy
		@scene = Scene.find(params[:id])
		@scene.destroy
		flash[:success] = "Scene deleted"
		redirect_to piece_scenes_url(@scene.piece_id)
	end

	private

	#setup for form - dropdowns, etc
	def form_setup
	end
end