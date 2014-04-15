class CastingsController < ApplicationController
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
		@casting = Casting.find(params[:id])
		@cast = @casting.cast
	end
	
	#setup for form - dropdowns, etc
	def form_setup
		@employees = Employee.active.map { |employee| [employee.full_name, employee.id] }
	end
end
