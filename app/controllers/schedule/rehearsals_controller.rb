class Schedule::RehearsalsController < ApplicationController
	load_resource :except => [:new, :create]
	authorize_resource
	layout 'tabs', :except => [:index, :new, :create, :destroy]

	def index
		query = params.except(:action, :controller)
		@rehearsals = @rehearsals.joins(:event).search(query).order("events.start_at DESC").paginate(page: params[:page], per_page: params[:per_page])
	end

	def new
		@rehearsal = Rehearsal.new(season_id: current_season.id)
		@rehearsal_form = RehearsalForm.new(@rehearsal)
	end

  def create
		@rehearsal = Rehearsal.new(season_id: current_season.id)
		@rehearsal_form = RehearsalForm.new(@rehearsal)
		if @rehearsal_form.submit(params[:rehearsal])
			redirect_to new_schedule_event_invitee_path(@rehearsal_form.event), :notice => "Successfully created the rehearsal."
		else
			render 'new'
		end
	end
	
	def edit
		@rehearsal_form = RehearsalForm.new(@rehearsal)
	end
	
	def update
		@rehearsal_form = RehearsalForm.new(@rehearsal)
		if @rehearsal_form.submit(params[:rehearsal])
			redirect_to schedule_rehearsals_path, :notice => "Successfully updated the rehearsal."
		else
			render 'edit'
		end
	end
	
	def show
	end
	
	def destroy
		@rehearsal.destroy
		redirect_to schedule_rehearsals_path, :notice => "Successfully deleted the rehearsal."
	end
	
	def scenes_by_piece
		@scenes = params[:piece_id].present? ? Piece.find(params[:piece_id]).scenes : []

		respond_to do |format|
			format.js
		end
	end
end
