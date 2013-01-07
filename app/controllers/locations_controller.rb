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
	
	def activate
		Location.find(params[:id]).activate
		flash[:success] = "Location activated"
		redirect_to :action => :inactive
	end
	
	def inactivate
		Location.find(params[:id]).inactivate
		flash[:success] = "Location inactivated"
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
