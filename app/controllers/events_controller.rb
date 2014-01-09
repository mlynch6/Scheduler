class EventsController < ApplicationController
  def index
  	@date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i) rescue Time.zone.today
  	@locations = Location.active.map { |location| location.name }
  	@events = Event.for_daily_calendar(@date).group_by(&:location_name)
	end
end
