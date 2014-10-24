class Schedule::CostumeFittingsController < ApplicationController
	load_resource :except => [:new, :create]
	authorize_resource
	layout 'tabs', :except => [:index, :new, :create, :destroy]

	def index
		query = params.except(:action, :controller)
		@costume_fittings = @costume_fittings.joins(:event).search(query).order("events.start_at ASC").paginate(page: params[:page], per_page: params[:per_page])
	end

	def new
		@costume_fitting_form = CostumeFittingForm.new
	end

  def create
		@costume_fitting_form = CostumeFittingForm.new
		if @costume_fitting_form.submit(params[:costume_fitting])
			redirect_to schedule_costume_fittings_path, :notice => "Successfully created the costume fitting."
		else
			render 'new'
		end
	end
	
	def edit
		@costume_fitting_form = CostumeFittingForm.new(@costume_fitting)
	end
	
	def update
		@costume_fitting_form = CostumeFittingForm.new(@costume_fitting)
		if @costume_fitting_form.submit(params[:costume_fitting])
			redirect_to schedule_costume_fitting_path(@costume_fitting), :notice => "Successfully updated the costume fitting."
		else
			render 'edit'
		end
	end
	
	def show
	end
	
	def destroy
		@costume_fitting.destroy
		redirect_to schedule_costume_fittings_path, :notice => "Successfully deleted the costume fitting."
	end
	
	def invitees
		@invitees = @costume_fitting.invitees
	end
	
	def edit_invitees
	end
	
	def update_invitees
		if @costume_fitting.event.update_attributes(params[:costume_fitting])
			redirect_to invitees_schedule_costume_fitting_path(@costume_fitting), :notice => "Successfully updated the invitees."
		else
			render 'edit'
		end
	end
end
