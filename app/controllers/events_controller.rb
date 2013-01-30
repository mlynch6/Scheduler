class EventsController < ApplicationController

  def index
  	@date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
  	@events = Event.for_daily_calendar(@date).includes(:location, :piece)
	end
end
