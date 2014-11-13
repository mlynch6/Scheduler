class Schedule::InviteesController < ApplicationController
	load_and_authorize_resource :event
	authorize_resource :invitees, :class => false
	layout 'tabs'
	
	def index
		@invitees = @event.invitees
		@artists = @event.artists
		@instructors = @event.instructors
		@musicians = @event.musicians
	end
	
	def new
	end
	
	def create
		if @event.update_attributes(params[:event])
			redirect_to schedule_event_invitees_path(@event), :notice => "Successfully updated the invitees."
		else
			render 'edit'
		end
	end
end
