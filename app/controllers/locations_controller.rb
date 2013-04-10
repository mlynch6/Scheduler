class LocationsController < ApplicationController
	#rescue_from ActiveRecord::RecordNotFound, :with => :redirect_index

  def index
  	@locations = Location.active.paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def inactive
  	@locations = Location.inactive.paginate(page: params[:page], per_page: params[:per_page])
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
		@location = Location.find(params[:id])
		form_setup
	end
	
	def update
		@location = Location.find(params[:id])
		if @location.update_attributes(params[:location])
			redirect_to locations_path, :notice => "Successfully updated the location."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		Location.find(params[:id]).destroy
		redirect_to locations_path, :notice => "Successfully deleted the location."
	end
	
	def activate
		Location.find(params[:id]).activate
		redirect_to inactive_locations_path, :notice => "Successfully activated the location."
	end
	
	def inactivate
		Location.find(params[:id]).inactivate
		redirect_to locations_path, :notice => "Successfully inactivated the location."
	end

	private

	#setup for form - dropdowns, etc
	def form_setup
	end
	
#	def redirect_index
#		flash[:error] = "Record Not Found"
#		redirect_to :action => :index
#	end
end
