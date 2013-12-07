class AgmaProfilesController < ApplicationController 
	before_filter :get_resource, :only => [:show]
	
  def show
	end
  
  def edit
		@agma_profile = AgmaProfile.first
		form_setup
	end
	
	def update
		@agma_profile = AgmaProfile.first
		if @agma_profile.update_attributes(params[:agma_profile])
			redirect_to agma_profile_path(@agma_profile), :notice => "Successfully updated the Contract Settings"
		else
			form_setup
			render 'edit'
		end
	end
	
private
	def get_resource
		@agma_profile = AgmaProfile.find(params[:id])
	end
	
	#setup for form - dropdowns, etc
	def form_setup
		@times = Lovs.time_array(15)
	end
end
