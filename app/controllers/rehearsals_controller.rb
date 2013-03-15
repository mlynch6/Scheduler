class RehearsalsController < ApplicationController
  def new
  	form_setup
		@rehearsal = Rehearsal.new
  end
  
  def create
		@rehearsal = Rehearsal.new(params[:rehearsal])
		if @rehearsal.save
			redirect_to events_path(:date => @rehearsal.start_date)
		else
			form_setup
			render 'new'
		end
	end
	
	def show
		@rehearsal = Rehearsal.find(params[:id])
	end
  
  private

	#setup for form - dropdowns, etc
	def form_setup
		@locations = Location.active.map { |location| [location.name, location.id] }
		@pieces = Piece.active.map { |piece| [piece.name, piece.id] }
		@employees = Employee.active.map { |employee| [employee.full_name, employee.id] }
	end
end
