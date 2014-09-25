class CastingsController < ApplicationController
	load_and_authorize_resource
	before_filter :get_resource, :only => [:edit, :update]
	
	def edit
		form_setup
	end
	
	def update
		if @casting.update_attributes(params[:casting])
			redirect_to season_piece_cast_path(@cast.season_piece, @cast), :notice => "Successfully updated the cast."
		else
			form_setup
			render 'edit'
		end
	end
	
private
	def get_resource
		@cast = @casting.cast
	end
	
	#setup for form - dropdowns, etc
	def form_setup
		@employees = Person.active.map { |person| [person.full_name, person.id] }
	end
end
