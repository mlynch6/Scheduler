class AgmaContractsController < ApplicationController 
	before_filter :get_resource
	load_and_authorize_resource
	
  def show
	end
  
  def edit
		form_setup
	end
	
	def update
		if @agma_contract.update_attributes(params[:agma_contract])
			redirect_to agma_contract_path(@agma_contract), :notice => "Successfully updated the Contract Settings"
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
