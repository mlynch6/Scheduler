class EventsController < ApplicationController
  def index
  	@date = params[:date] ? Date.parse(params[:date]) : Time.zone.today
  	@locations = Location.active.map { |location| location.name }
  	@events = Event.for_daily_calendar(@date).joins(:location).select("events.*, locations.name as location_name").order("locations.name").group_by(&:location_name)
	end
end
