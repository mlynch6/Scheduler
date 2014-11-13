class Schedule::CompanyClassesController < ApplicationController
	load_resource :except => [:new, :create]
	authorize_resource
	layout 'tabs', :only => [:show, :dates]

	def index
		query = params.except(:action, :controller)
		@company_classes = @company_classes.search(query).paginate(page: params[:page], per_page: params[:per_page])
	end

	def new
		@company_class = CompanyClass.new(season_id: current_season.id)
		@company_class_form = CompanyClassForm.new(@company_class)
	end
	
	def create
		@company_class = CompanyClass.new(season_id: current_season.id)
		@company_class_form = CompanyClassForm.new(@company_class)
		if @company_class_form.submit(params[:company_class])
			redirect_to dates_schedule_company_class_path(@company_class_form.company_class), :notice => "Successfully created the company class."
		else
			render 'new'
		end
	end
	
	def edit
	end
	
	def update
		if @company_class.update_attributes(params[:company_class])
			redirect_to schedule_company_classes_path, :notice => "Successfully updated the company class."
		else
			render 'edit'
		end
	end
	
	def show
	end
	
	def destroy
		@company_class.destroy
		redirect_to schedule_company_classes_path, :notice => "Successfully deleted the company class."
	end
	
	def dates
		@events = @company_class.events
	end
end
