class EventsController < ApplicationController
	before_filter :get_resource, :only => [:edit, :update, :destroy, :show]
	
  def index
  	params[:year] ||= Time.zone.today.year
  	params[:month] ||= Time.zone.today.month
  	params[:day] ||= Time.zone.today.day
  	@events = Event.between(Time.at(params[:start].to_i).to_s(:db), Time.at(params[:end].to_i).to_s(:db))
		
		render layout: "public_application"
	end
	
	def show
		respond_to do |format|
			format.html { redirect_to events_path }
			format.js { render :layout => false }
		end
	end
	
	def new
  	form_setup
  	type = params[:event_type] || 'Event'
  	@event = Event.new_with_subclass(type)
  	@event.event_type = type
  	@event.start_date = params[:date]
  end
  
  def create
  	@event = Event.new_with_subclass(params[:event][:event_type], params[:event])
  	
		if @event.valid?
			if params[:event][:period] == "Never"
				save_success = @event.save
			else
				@series = EventSeries.new(params[:event])
				save_success = @series.save
				add_series_errors_to_event
			end
			
			if save_success
				flash[:success] = "Successfully created the #{readable_type}."
				show_warnings
				redirect_to events_path+"/"+@event.start_at.strftime('%Y/%m/%d')
			else
				form_setup
				@event.start_time ||= params[:event][:start_time]
				render 'new'
			end
		else
			form_setup
			render 'new'
		end
	end
	
	def edit
		form_setup
		@event.event_type = @event.type
	end

	def update
#		case params[:event][:commit]
#			when "Only This Event"
#			when "All Future Events"
#			else
				save_success = @event.update_attributes(params[:event])
#		end
#		
		if save_success
			flash[:success] = "Successfully updated the #{readable_type}."
			show_warnings
			redirect_to events_path+"/"+@event.start_at.strftime('%Y/%m/%d')
		else
			form_setup
			render 'edit'
		end
	end
	
	def destroy
		if @event.event_series
			params[:mode] ||= 'single'
			@event.event_series.destroy_event(params[:mode], @event)
		else
			@event.destroy
		end
		
		flash[:success] = "Successfully deleted the #{readable_type}."
		redirect_to events_path+"/"+@event.start_at.strftime('%Y/%m/%d')
	end

private
	def get_resource
		@event = Event.find(params[:id])
		if @event.event_series
			@event.period = @event.event_series.period
			@event.end_date = @event.event_series.end_date
		end
	end

	#setup for form - dropdowns, etc
	def form_setup
		@locations = Location.active.map { |location| [location.name, location.id] }
		@employees = Employee.active.map { |employee| [employee.full_name, employee.id] }
		@pieces = Piece.all.map { |piece| [piece.name_w_choreographer, piece.id] }
	end
	
	def show_warnings
		@event.warnings.each do |key, msg|
			flash[:warning] = msg
		end
	end
	
	def add_series_errors_to_event
		@series.errors.each do |attrib, msg|
			@event.errors.add(attrib, msg)
		end
	end
	
	def readable_type
		type = @event.type || params[:event][:event_type]
		type.underscore.humanize.titleize
	end
end
