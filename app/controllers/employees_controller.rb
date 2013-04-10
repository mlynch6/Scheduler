class EmployeesController < ApplicationController
	#rescue_from ActiveRecord::RecordNotFound, :with => :redirect_index

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
		@employee = Employee.find(params[:id])
	end
	
	def edit
		@employee = Employee.find(params[:id])
		form_setup
	end
	
	def update
		@employee = Employee.find(params[:id])
		if @employee.update_attributes(params[:employee])
			redirect_to employees_path, :notice => "Successfully updated the employee."
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		Employee.find(params[:id]).destroy
		redirect_to employees_path, :notice => "Successfully deleted the employee."
	end
	
	def activate
		Employee.find(params[:id]).activate
		redirect_to inactive_employees_path, :notice => "Successfully activated the employee."
	end
	
	def inactivate
		Employee.find(params[:id]).inactivate
		redirect_to employees_path, :notice => "Successfully inactivated the employee."
	end

	private

	#setup for form - dropdowns, etc
	def form_setup
	end
	
#	def redirect_index
#		flash[:error] = "Record Not Found"
#		redirect_to :action => :index
#	end
end
