class RehearsalBreaksController < ApplicationController
	before_filter :get_resource, :only => [:destroy]

	def new
		form_setup
		@agma_contract = AgmaContract.find(params[:agma_contract_id])
		@rehearsal_break = @agma_contract.rehearsal_breaks.build
	end

	def create		
		@agma_contract = AgmaContract.find(params[:agma_contract_id])
		@rehearsal_break = @agma_contract.rehearsal_breaks.build(params[:rehearsal_break])

		if @rehearsal_break.save
			redirect_to agma_contract_path(@agma_contract), :notice => "Successfully created the break."
		else
			form_setup
			render "new"
		end
	end

	def destroy
		@rehearsal_break.destroy
		redirect_to agma_contract_path(@rehearsal_break.agma_contract), :notice => "Successfully deleted the break."
	end

private
	def get_resource
		@rehearsal_break = RehearsalBreak.find(params[:id])
	end

	#setup for form - dropdowns, etc
	def form_setup
	end
end
