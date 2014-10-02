class Schedule::RehearsalsController < ApplicationController
	load_resource :except => [:new, :create]
	authorize_resource

	def index
		query = params.except(:action, :controller)
		@rehearsals = @rehearsals.joins(:event).search(query).order("events.start_at ASC").paginate(page: params[:page], per_page: params[:per_page])
	end

	def new
		@rehearsal_form = RehearsalForm.new
	end

  def create
		@rehearsal_form = RehearsalForm.new
		if @rehearsal_form.submit(params[:rehearsal])
			redirect_to schedule_rehearsals_path, :notice => "Successfully created the rehearsal."
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
