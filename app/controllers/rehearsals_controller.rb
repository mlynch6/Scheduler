class RehearsalsController < ApplicationController
	before_filter :get_resource, :only => [:show, :edit, :update]
	
  def new
  	form_setup
		@rehearsal = Rehearsal.new
		@rehearsal.start_date = params[:date] if params[:date].present?
  end
  
  def create
		@rehearsal = Rehearsal.new(params[:rehearsal])
		if @rehearsal.save
			flash[:success] = "Successfully created the rehearsal."
			show_warnings(@rehearsal.start_at)
			redirect_to events_path+"/"+@rehearsal.start_date.strftime('%Y/%m/%d')
		else
			form_setup
			render 'new'
		end
	end
	
	def show
	end
	
	def edit
		@rehearsal.start_date = @rehearsal.start_date
		@rehearsal.start_time = @rehearsal.start_time
		@rehearsal.end_time = @rehearsal.end_time
		form_setup
	end
	
	def update
		if @rehearsal.update_attributes(params[:rehearsal])
			flash[:success] = "Successfully updated the rehearsal."
			show_warnings(@rehearsal.start_date)
			redirect_to events_path+"/"+@rehearsal.start_date.strftime('%Y/%m/%d')
		else
			form_setup
			render 'edit'
		end
	end
  
private
	def get_resource
		@rehearsal = Rehearsal.find(params[:id])
	end
	
	#setup for form - dropdowns, etc
	def form_setup
		@locations = Location.active.map { |location| [location.name, location.id] }
		@pieces = Piece.active.map { |piece| [piece.name, piece.id] }
		@employees = Employee.active.map { |employee| [employee.full_name, employee.id] }
	end
	
	def show_warnings(date)
		warnings = []
		
		db_employee_msg = @rehearsal.double_booked_employees_warning
		warnings << db_employee_msg if db_employee_msg.present?
		
		max_hr_per_day_msg = Employee.max_rehearsal_hrs_in_day_warning(date)
		warnings << max_hr_per_day_msg if max_hr_per_day_msg.present?
		
		max_hr_per_week_msg = Employee.max_rehearsal_hrs_in_week_warning(date)
		warnings << max_hr_per_week_msg if max_hr_per_week_msg.present?
		
		flash[:warning] = warnings if warnings.any?
	end
end
