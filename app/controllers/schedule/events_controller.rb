class Schedule::EventsController < ApplicationController
	load_and_authorize_resource
	layout 'tabs', :only => [:show]

	def index
		params[:year] ||= Time.zone.today.year
		params[:month] ||= Time.zone.today.month
		params[:day] ||= Time.zone.today.day
		@event_date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    
		if params[:range] == 'week'
			@date_range = @event_date.beginning_of_week..@event_date.end_of_week
	    @previous_day = @event_date - 1.week
	    @next_day = @event_date + 1.week
		else
			@date_range = @event_date..@event_date
	    @previous_day = @event_date - 1.day
	    @next_day = @event_date + 1.day
		end
		
		query = params.except(:action, :controller, :year, :month, :day)
		query[:date] = @event_date
		@events = @events.search(query)
		@events_by_date = @events.group_by { |e| e.start_at.to_date }
	end
	
	def show
	end
	
	def destroy
		@event.destroy
		redirect_to schedule_events_path+@event.start_at.strftime('/%Y/%-m/%-d'), :notice => "Successfully deleted the event."
	end
end
