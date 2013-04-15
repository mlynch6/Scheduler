class EventsController < ApplicationController
  def index
  	@date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
  	@locations = Location.active.map { |location| location.name }
  	@events = Event.for_daily_calendar(@date).group_by(&:location_name)
	end
end
