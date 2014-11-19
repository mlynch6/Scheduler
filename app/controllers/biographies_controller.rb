class BiographiesController < ApplicationController
	load_and_authorize_resource :employee
	authorize_resource :biography, :class => false
	layout 'tabs'
	
	def show
	end
	
	def edit
	end
	
	def update
		if @employee.update_attributes(params[:employee])
			redirect_to employee_biography_path(@employee), :notice => "Successfully updated the employee's biography."
		else
			render 'edit'
		end
	end
end
