class Company::Contract::CostumeFittingController < ApplicationController
	before_filter :get_resource
	layout 'tabs'
	
  def show
		authorize! :show, :contract_costume_fitting
  end
	
  def edit
		authorize! :edit, :contract_costume_fitting
  end
	
  def update
		authorize! :update, :contract_costume_fitting
		if @agma_contract.update_attributes(params[:agma_contract])
			redirect_to company_contract_costume_fitting_path, :notice => "Successfully updated the Costume Fitting Settings"
		else
			render 'edit'
		end
  end
	
private
	def get_resource
		@agma_contract = AgmaContract.first
	end
end
