class ScenesController < ApplicationController
	def index
		@piece = Piece.find(params[:piece_id])
		@scenes = @piece.scenes
		respond_to do |format|
			format.html
			format.pdf do
				pdf = ScenePdf.new(@piece, view_context)
				send_data pdf.render, filename: "#{@piece.name} by Scene.pdf", type: "application/pdf"
			end
		end
	end
	
	def new
		@piece = Piece.find(params[:piece_id])
		@scene = @piece.scenes.build
		form_setup(@piece)
	end
	
	def create
		@piece = Piece.find(params[:piece_id])
		@scene = @piece.scenes.build(params[:scene])
		
		if @scene.save
			redirect_to piece_scenes_path(@piece), :notice => "Successfully created the scene."
		else
			form_setup(@piece)
			render 'new'
		end
	end
	
	def edit
		@scene = Scene.includes(:piece).find(params[:id])
		@piece = @scene.piece
		form_setup(@piece)
	end
	
	def update
		@scene = Scene.includes(:piece).find(params[:id])
		@piece = @scene.piece
		
		if @scene.update_attributes(params[:scene])
			redirect_to piece_scenes_path(@piece), :notice => "Successfully updated the scene."
		else
			form_setup(@piece)
			render 'edit'
		end
	end
	
	def destroy
		@scene = Scene.find(params[:id])
		@scene.destroy
		redirect_to piece_scenes_path(@scene.piece_id), :notice => "Successfully deleted the scene."
	end

	def sort
		params[:scene].each_with_index do |id, index|
			Scene.update_all({ position: index+1 }, { id: id })
		end
		render nothing: true
	end
	
	private

	#setup for form - dropdowns, etc
	def form_setup(piece)
		@characters = piece.characters.map { |character| [character.name, character.id] }
	end
end
