class Company::Contract::RehearsalWeeksController < ApplicationController
	before_filter :get_resource
	layout 'tabs'
	
  def show
		authorize! :show, :contract_rehearsal_week
  end
	
  def edit
		authorize! :edit, :contract_rehearsal_week
		form_setup
  end
	
  def update
		authorize! :update, :contract_rehearsal_week
		if @agma_contract.update_attributes(params[:agma_contract])
			redirect_to company_contract_rehearsal_week_path, :notice => "Successfully updated the Rehearsal Week Settings"
		else
			form_setup
			render 'edit'
		end
  end
	
private
	def get_resource
		@agma_contract = AgmaContract.first
	end
	
	#setup for form - dropdowns, etc
	def form_setup
		@times = Lovs.time_array(15)
	end
end
