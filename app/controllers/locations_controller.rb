class LocationsController < ApplicationController
	before_filter :get_resource, :only => [:edit, :update, :destroy, :activate, :inactivate]

  def index
  	query = params.except(:action, :controller)
  	@locations = Location.search(query).paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def new
		form_setup
		@location = Location.new
	end
	
	def create
		@location = Location.new(params[:location])
		if @location.save
			redirect_to locations_path, :notice => "Successfully created the location."
		else
			form_setup
			render 'new'
		end
	end
	
	def edit
		form_setup
	end
	
	def update
		if @location.update_attributes(params[:location])
			redirect_to locations_path, :notice => "Successfully updated the location."
		else
			form_setup
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

private
	def get_resource
		@location = Location.find(params[:id])
	end
	
	#setup for form - dropdowns, etc
	def form_setup
	end
end
