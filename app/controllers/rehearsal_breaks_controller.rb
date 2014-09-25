class RehearsalBreaksController < ApplicationController
	load_and_authorize_resource :agma_contract, only: [:new, :create]
	load_and_authorize_resource :rehearsal_break, :through => :agma_contract, :shallow => true

	def new
	end

	def create		
		if @rehearsal_break.save
			redirect_to agma_contract_path(@agma_contract), :notice => "Successfully created the break."
		else
			render "new"
		end
	end

	def destroy
		@rehearsal_break.destroy
		redirect_to agma_contract_path(@rehearsal_break.agma_contract), :notice => "Successfully deleted the break."
	end
end
