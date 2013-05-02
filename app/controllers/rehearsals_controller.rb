class RehearsalsController < ApplicationController
  def new
  	form_setup
		@rehearsal = Rehearsal.new
		@rehearsal.start_date = Time.parse(params[:date]).strftime("%m/%d/%Y") if params[:date].present?
  end
  
  def create
		@rehearsal = Rehearsal.new(params[:rehearsal])
		if @rehearsal.save
			flash[:success] = "Successfully created the rehearsal."
			show_warnings
			redirect_to events_path(:date => @rehearsal.start_date)
		else
			form_setup
			render 'new'
		end
	end
	
	def show
		@rehearsal = Rehearsal.find(params[:id])
	end
	
	def edit
		@rehearsal = Rehearsal.find(params[:id])
		@rehearsal.start_date = @rehearsal.start_date
		@rehearsal.start_time = @rehearsal.start_time
		@rehearsal.end_time = @rehearsal.end_time
		form_setup
	end
	
	def update
		@rehearsal = Rehearsal.find(params[:id])
		if @rehearsal.update_attributes(params[:rehearsal])
			flash[:success] = "Successfully updated the rehearsal."
			show_warnings
			redirect_to events_path(:date => @rehearsal.start_date)
		else
			form_setup
			render 'edit'
		end
	end
  
  private

	#setup for form - dropdowns, etc
	def form_setup
		@locations = Location.active.map { |location| [location.name, location.id] }
		@pieces = Piece.active.map { |piece| [piece.name, piece.id] }
		@employees = Employee.active.map { |employee| [employee.full_name, employee.id] }
	end
	
	def show_warnings
		db_employee_msg = @rehearsal.double_booked_employees_warning
		flash[:warning] = db_employee_msg if db_employee_msg.present?
	end
end
