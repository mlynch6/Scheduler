class CompanyClassesController < ApplicationController
  def new
  	form_setup
		@cclass = CompanyClass.new
		@cclass.start_date = params[:date] if params[:date].present?
  end
  
  def create
		@cclass = CompanyClass.new(params[:company_class])
		if @cclass.save
			flash[:success] = "Successfully created the company class."
			show_warnings
			redirect_to events_path(:date => @cclass.start_date)
		else
			form_setup
			render 'new'
		end
	end
	
	def show
		@cclass = CompanyClass.find(params[:id])
	end
	
	def edit
		@cclass = CompanyClass.find(params[:id])
		@cclass.start_date = @cclass.start_date
		@cclass.start_time = @cclass.start_time
		@cclass.end_time = @cclass.end_time
		form_setup
	end
	
	def update
		@cclass = CompanyClass.find(params[:id])
		if @cclass.update_attributes(params[:company_class])
			flash[:success] = "Successfully updated the company class."
			show_warnings
			redirect_to events_path(:date => @cclass.start_date)
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
		db_employee_msg = @cclass.double_booked_employees_warning
		flash[:warning] = db_employee_msg if db_employee_msg.present?
	end
end
