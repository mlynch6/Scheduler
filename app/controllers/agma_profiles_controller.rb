class AgmaProfilesController < ApplicationController  
  def show
		@agma_profile = AgmaProfile.find(params[:id])
	end
  
  def edit
		@agma_profile = AgmaProfile.first
		form_setup
	end
	
	def update
		@agma_profile = AgmaProfile.first
		if @agma_profile.update_attributes(params[:agma_profile])
			redirect_to agma_profile_path(@agma_profile), :notice => "Successfully updated the Rehearsal Week Settings"
		else
			form_setup
			render 'edit'
		end
	end
	
	private

	#setup for form - dropdowns, etc
	def form_setup
		@times = Lovs.time_array(15)
	end
end
