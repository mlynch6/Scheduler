class Schedule::LectureDemosController < ApplicationController
	load_resource :except => [:new, :create]
	authorize_resource
	layout 'tabs', :except => [:index, :new, :create, :destroy]

	def index
		query = params.except(:action, :controller)
		@lecture_demos = @lecture_demos.joins(:event).search(query).order("events.start_at ASC").paginate(page: params[:page], per_page: params[:per_page])
	end

	def new
		@lecture_demo_form = LectureDemoForm.new
	end

  def create
		@lecture_demo_form = LectureDemoForm.new
		if @lecture_demo_form.submit(params[:lecture_demo])
			redirect_to schedule_lecture_demos_path, :notice => "Successfully created the lecture demonstration."
		else
			render 'new'
		end
	end
	
	def edit
		@lecture_demo_form = LectureDemoForm.new(@lecture_demo)
	end
	
	def update
		@lecture_demo_form = LectureDemoForm.new(@lecture_demo)
		if @lecture_demo_form.submit(params[:lecture_demo])
			redirect_to schedule_lecture_demos_path, :notice => "Successfully updated the lecture demonstration."
		else
			render 'edit'
		end
	end
	
	def show
	end
	
	def destroy
		@lecture_demo.destroy
		redirect_to schedule_lecture_demos_path, :notice => "Successfully deleted the lecture demonstration."
	end
	
	def invitees
		@invitees = @lecture_demo.invitees
	end
	
	def edit_invitees
	end
	
	def update_invitees
		if @lecture_demo.event.update_attributes(params[:lecture_demo])
			redirect_to invitees_schedule_lecture_demo_path(@lecture_demo), :notice => "Successfully updated the invitees."
		else
			render 'edit'
		end
	end
end
