class CompanyClassesController < ApplicationController
  def new
  	form_setup
		@cclass = CompanyClass.new
  end
  
  def create
		@cclass = CompanyClass.new(params[:company_class])
		if @cclass.save
			redirect_to events_path(:date => @cclass.start_date)
		else
			form_setup
			render 'new'
		end
	end
	
	def show
		#@cclass = CompanyClass.find(params[:id])
	end
  
  private

	#setup for form - dropdowns, etc
	def form_setup
		@locations = Location.active.map { |location| [location.name, location.id] }
		@employees = Employee.active.map { |employee| [employee.full_name, employee.id] }
	end
end
