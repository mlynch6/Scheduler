class EmployeesController < ApplicationController
	load_resource :except => [:new, :create]
	authorize_resource
	layout 'tabs', :only => [:show, :edit, :update]

  def index
		params[:status] ||= 'active'
		query = params.except(:action, :controller)
		@employees = @employees.search(query).joins(:person).order("people.last_name ASC, people.first_name ASC").paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def new
		@employee_form = EmployeeForm.new
	end
	
	def create
		@employee_form = EmployeeForm.new
		if @employee_form.submit(params[:employee])
			redirect_to employees_path, :notice => "Successfully created the employee."
		else
			render 'new'
		end
	end
	
	def show
	end
	
	def edit
		@employee_form = EmployeeForm.new(@employee)
	end
	
	def update
		@employee_form = EmployeeForm.new(@employee)
		if @employee_form.submit(params[:employee])
			redirect_to employee_path(@employee), :notice => "Successfully updated the employee."
		else
			render 'edit'
		end
	end
	
	def destroy
		@employee.destroy
		redirect_to employees_path, :notice => "Successfully deleted the employee."
	end
	
	def activate
		@employee.activate
		redirect_to employees_path, :notice => "Successfully activated the employee."
	end
	
	def inactivate
		@employee.inactivate
		redirect_to employees_path, :notice => "Successfully inactivated the employee."
	end
end
