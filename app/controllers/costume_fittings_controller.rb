class CostumeFittingsController < ApplicationController
  def new
  	form_setup
		@fitting = CostumeFitting.new
		@fitting.start_date = Time.parse(params[:date]).strftime("%m/%d/%Y") if params[:date].present?
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
		@fitting = CostumeFitting.find(params[:id])
	end
	
	def edit
		@fitting = CostumeFitting.find(params[:id])
		@fitting.start_date = @fitting.start_date
		@fitting.start_time = @fitting.start_time
		@fitting.end_time = @fitting.end_time
		form_setup
	end
	
	def update
		@fitting = CostumeFitting.find(params[:id])
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
