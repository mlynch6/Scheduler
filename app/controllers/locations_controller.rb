class LocationsController < ApplicationController
	load_and_authorize_resource

  def index
  	query = params.except(:action, :controller)
  	@locations = @locations.search(query).paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def new
	end
	
	def create
		if @location.save
			redirect_to locations_path, :notice => "Successfully created the location."
		else
			render 'new'
		end
	end
	
	def edit
	end
	
	def update
		if @location.update_attributes(params[:location])
			redirect_to locations_path, :notice => "Successfully updated the location."
		else
			render 'edit'
		end
	end
	
	def destroy
		@location.destroy
		redirect_to locations_path, :notice => "Successfully deleted the location."
	end
	
	def activate
		@location.activate
		redirect_to locations_path(status: "active"), :notice => "Successfully activated the location."
	end
	
	def inactivate
		@location.inactivate
		redirect_to locations_path(status: "inactive"), :notice => "Successfully inactivated the location."
	end
end
