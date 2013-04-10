class RehearsalsController < ApplicationController
  def new
  	form_setup
		@rehearsal = Rehearsal.new
		@rehearsal.start_date = Time.parse(params[:date]).strftime("%m/%d/%Y") if params[:date].present?
  end
  
  def create
		@rehearsal = Rehearsal.new(params[:rehearsal])
		if @rehearsal.save
			redirect_to events_path(:date => @rehearsal.start_date), :notice => "Successfully created the rehearsal."
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
			redirect_to events_path(:date => @rehearsal.start_date), :notice => "Successfully updated the rehearsal."
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
end
