class Company::Contract::CompanyClassController < ApplicationController
	before_filter :get_resource
	layout 'tabs'
	
  def show
		authorize! :show, :contract_company_class
  end
	
  def edit
		authorize! :edit, :contract_company_class
  end
	
  def update
		authorize! :update, :contract_company_class
		if @agma_contract.update_attributes(params[:agma_contract])
			redirect_to company_contract_company_class_path, :notice => "Successfully updated the Company Class Settings"
		else
			render 'edit'
		end
  end
	
private
	def get_resource
		@agma_contract = AgmaContract.first
	end
end
