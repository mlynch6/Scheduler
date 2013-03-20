class AgmaProfilesController < ApplicationController  
  def edit
		@agma_profile = AgmaProfile.first
		form_setup
	end
	
	def update
		@agma_profile = AgmaProfile.first
		if @agma_profile.update_attributes(params[:agma_profile])
			flash[:success] = "Settings saved"
			redirect_to account_path(@agma_profile.account)
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
