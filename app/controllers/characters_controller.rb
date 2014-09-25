class CharactersController < ApplicationController
	load_and_authorize_resource :piece, only: [:index, :new, :create]
	load_and_authorize_resource :character, :through => :piece, :shallow => true

	def index
		@characters = @characters.active
	end
	
	def new
	end
	
	def create
		if @character.save
			redirect_to piece_characters_path(@piece), :notice => "Successfully created the character."
		else
			render 'new'
		end
	end
	
	def edit
		@piece = @character.piece
	end
	
	def update
		@piece = @character.piece
		if @character.update_attributes(params[:character])
			redirect_to piece_characters_path(@piece), :notice => "Successfully updated the character."
		else
			render 'edit'
		end
	end
	
	def destroy
		@character.soft_delete
		redirect_to piece_characters_path(@character.piece_id), :notice => "Successfully deleted the character."
	end

	def sort
		params[:character].each_with_index do |id, index|
			Character.update_all({ position: index+1 }, { id: id })
		end
		render nothing: true
	end
end
