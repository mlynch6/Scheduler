class Company::Contract::LectureDemoController < ApplicationController
	before_filter :get_resource
	layout 'tabs'
	
  def show
		authorize! :show, :contract_lecture_demo
  end
	
  def edit
		authorize! :edit, :contract_lecture_demo
  end
	
  def update
		authorize! :update, :contract_lecture_demo
		if @agma_contract.update_attributes(params[:agma_contract])
			redirect_to company_contract_lecture_demo_path, :notice => "Successfully updated the Lecture Demo Settings"
		else
			render 'edit'
		end
  end
	
private
	def get_resource
		@agma_contract = AgmaContract.first
	end
end
