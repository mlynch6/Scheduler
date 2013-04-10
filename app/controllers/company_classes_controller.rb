class CompanyClassesController < ApplicationController
  def new
  	form_setup
		@cclass = CompanyClass.new
		@cclass.start_date = Time.parse(params[:date]).strftime("%m/%d/%Y") if params[:date].present?
  end
  
  def create
		@cclass = CompanyClass.new(params[:company_class])
		if @cclass.save
			redirect_to events_path(:date => @cclass.start_date), notice: "Successfully created the company class."
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
			redirect_to events_path(:date => @cclass.start_date), :notice => "Successfully updated the company class."
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
end
