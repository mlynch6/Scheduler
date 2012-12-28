class LocationsController < ApplicationController
	#rescue_from ActiveRecord::RecordNotFound, :with => :redirect_index

  def index
  	if params[:status] == "inactive"
			@locations = Location.inactive.paginate(page: params[:page], per_page: params[:per_page])
		else
			@locations = Location.active.paginate(page: params[:page], per_page: params[:per_page])
		end
	end
	
	def new
		form_setup
		@location = Location.new
	end
	
	def create
		@location = Location.new(params[:location])
		if @location.save
			flash[:success] = "Location created"
			redirect_to locations_path
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
			flash[:success] = "Location saved"
			redirect_to locations_path
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		Location.find(params[:id]).destroy
		flash[:success] = "Location deleted"
		redirect_to :action => :index
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
