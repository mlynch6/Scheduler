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
			flash[:success] = "Employee created"
			redirect_to employees_path
		else
			form_setup
			render 'new'
		end
	end
	
	def edit
		@employee = Employee.find(params[:id])
		form_setup
	end
	
	def update
		@employee = Employee.find(params[:id])
		if @employee.update_attributes(params[:employee])
			flash[:success] = "Employee saved"
			redirect_to employees_path
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		Employee.find(params[:id]).destroy
		flash[:success] = "Employee deleted"
		redirect_to :action => :index
	end
	
	def activate
		Employee.find(params[:id]).activate
		flash[:success] = "Employee activated"
		redirect_to :action => :inactive
	end
	
	def inactivate
		Employee.find(params[:id]).inactivate
		flash[:success] = "Employee inactivated"
		redirect_to :action => :index
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
