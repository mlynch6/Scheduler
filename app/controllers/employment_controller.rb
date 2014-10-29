class EmploymentController < ApplicationController
	load_and_authorize_resource :employee
	authorize_resource :employment, :class => false
	layout 'tabs'
	
	def show
	end
	
	def edit
	end
	
	def update
		if @employee.update_attributes(params[:employee])
			redirect_to employee_employment_path(@employee), :notice => "Successfully updated the employee's employment."
		else
			render 'edit'
		end
	end
end
