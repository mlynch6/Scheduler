class CharactersController < ApplicationController
	def index
		@piece = Piece.find(params[:piece_id])
		@characters = @piece.characters
	end
	
	def new
		form_setup
		@piece = Piece.find(params[:piece_id])
		@character = @piece.characters.build
	end
	
	def create
		@piece = Piece.find(params[:piece_id])
		@character = @piece.characters.build(params[:character])
		
		if @character.save
			redirect_to piece_characters_path(@piece), :notice => "Successfully created the character."
		else
			form_setup
			render 'new'
		end
	end
	
	def edit
		@character = Character.includes(:piece).find(params[:id])
		@piece = @character.piece
		form_setup
	end
	
	def update
		@character = Character.includes(:piece).find(params[:id])
		@piece = @character.piece
		
		if @character.update_attributes(params[:character])
			redirect_to piece_characters_path(@piece), :notice => "Successfully updated the character."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		@character = Character.find(params[:id])
		@character.destroy
		redirect_to piece_characters_path(@character.piece_id), :notice => "Successfully deleted the character."
	end

	def sort
		params[:character].each_with_index do |id, index|
			Character.update_all({ position: index+1 }, { id: id })
		end
		render nothing: true
	end
	
private

	#setup for form - dropdowns, etc
	def form_setup
	end
end
