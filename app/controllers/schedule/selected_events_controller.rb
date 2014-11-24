class Schedule::SelectedEventsController < ApplicationController
	authorize_resource :selected_events, :class => false

	def create
		if params[:event_ids].present?
			@events = Event.find(params[:event_ids])
			@event = @events.first
			
			if params[:commit] == 'Update'
				@events.reject! do |event|
					event.update_attributes(params[:event].reject { |k,v| v.blank? })
				end
				redirect_to dates_schedule_company_class_path(@event.schedulable), :notice => "Successfully updated the selected events." if @events.empty?
			else
				render 'new'
			end
		else
			redirect_to :back
		end
	end
end
