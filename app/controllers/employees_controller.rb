class EmployeesController < ApplicationController
	before_filter :get_resource, :only => [:show, :edit, :update, :destroy, :activate, :inactivate]

  def index
  	@employees = Employee.active.paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def inactive
  	@employees = Employee.inactive.paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def new
		form_setup
		@employee = Employee.new
	end
	
	def create
		@employee = Employee.new(params[:employee])
		if @employee.save
			redirect_to employees_path, :notice => "Successfully created the employee."
		else
			form_setup
			render 'new'
		end
	end
	
	def show
	end
	
	def edit
		form_setup
	end
	
	def update
		if @employee.update_attributes(params[:employee])
			redirect_to employees_path, :notice => "Successfully updated the employee."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		@employee.destroy
		redirect_to employees_path, :notice => "Successfully deleted the employee."
	end
	
	def activate
		@employee.activate
		redirect_to inactive_employees_path, :notice => "Successfully activated the employee."
	end
	
	def inactivate
		@employee.inactivate
		redirect_to employees_path, :notice => "Successfully inactivated the employee."
	end

private
	def get_resource
		@employee = Employee.find(params[:id])
	end
	
	#setup for form - dropdowns, etc
	def form_setup
	end
end
