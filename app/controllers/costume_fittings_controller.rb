class CostumeFittingsController < ApplicationController
	before_filter :get_resource, :only => [:show, :edit, :update]
	
  def new
  	form_setup
		@fitting = CostumeFitting.new
		@fitting.start_date = params[:date] if params[:date].present?
  end
  
  def create
		@fitting = CostumeFitting.new(params[:costume_fitting])
		if @fitting.save
			flash[:success] = "Successfully created the costume fitting."
			show_warnings
			redirect_to events_path(:date => @fitting.start_date)
		else
			form_setup
			render 'new'
		end
	end
	
	def show
	end
	
	def edit
		@fitting.start_date = @fitting.start_date
		@fitting.start_time = @fitting.start_time
		@fitting.end_time = @fitting.end_time
		form_setup
	end
	
	def update
		if @fitting.update_attributes(params[:costume_fitting])
			flash[:success] = "Successfully updated the costume fitting."
			show_warnings
			redirect_to events_path(:date => @fitting.start_date)
		else
			form_setup
			render 'edit'
		end
	end
  
private
	def get_resource
		@fitting = CostumeFitting.find(params[:id])
	end

	#setup for form - dropdowns, etc
	def form_setup
		@locations = Location.active.map { |location| [location.name, location.id] }
		@employees = Employee.active.map { |employee| [employee.full_name, employee.id] }
	end
	
	def show_warnings
		db_employee_msg = @fitting.double_booked_employees_warning
		flash[:warning] = db_employee_msg if db_employee_msg.present?
	end
end
