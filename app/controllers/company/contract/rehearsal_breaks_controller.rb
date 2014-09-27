class Company::Contract::RehearsalBreaksController < ApplicationController
	before_filter :load_and_authorize_parent, only: [:new, :create]
	load_and_authorize_resource :rehearsal_break, :through => :agma_contract, :shallow => true

	def new
	end

	def create		
		if @rehearsal_break.save
			redirect_to company_contract_rehearsal_week_path, :notice => "Successfully created the break."
		else
			render "new"
		end
	end

	def destroy
		@rehearsal_break.destroy
		redirect_to company_contract_rehearsal_week_path, :notice => "Successfully deleted the break."
	end
	
private
	def load_and_authorize_parent
		@agma_contract = AgmaContract.first
		authorize! :read, @agma_contract
	end
end
