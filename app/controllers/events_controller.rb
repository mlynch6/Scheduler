class EventsController < ApplicationController
	before_filter :get_resource, :only => [:edit, :update, :destroy, :show]

	def index
		params[:year] ||= Time.zone.today.year
		params[:month] ||= Time.zone.today.month
		params[:day] ||= Time.zone.today.day
		@events = Event.between(Time.at(params[:start].to_i).to_s(:db), Time.at(params[:end].to_i).to_s(:db))
	end
	
	def show
		respond_to do |format|
			format.html { redirect_to events_path }
			format.js { render :layout => false }
		end
	end
	
	def new
		form_setup

		attrib = Hash.new
		attrib[:event_type] = params[:event_type] || 'Event'
		attrib[:start_date] = Date.strptime(params[:dt], '%m-%d-%Y') if params[:dt] && params[:dt].present?
		attrib[:start_time] = Time.strptime(params[:tm], '%H%M').to_s(:hr12) if params[:tm] && params[:tm].present?
		attrib[:period] = 'Never'
  	
		@event = Event.new_with_subclass(attrib[:event_type], attrib)
	end

  def create
		@event = Event.new_with_subclass(params[:event][:event_type], params[:event])
  	
		if @event.valid?
			if params[:event][:period] == "Never"
				save_success = @event.save
			else
				@series = EventSeries.new(params[:event])
				save_success = @series.save
				add_series_errors_to_event(@series)
			end
			
			if save_success
				flash[:success] = "Successfully created the #{readable_type}."
				show_warnings
				redirect_to events_path+"/"+@event.start_at.strftime('%Y/%m/%d')
			else
				form_setup
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
		if @series
			mode = get_update_mode(params[:commit])
			save_success = @series.update_event(mode, @event, params[:event])
			add_series_errors_to_event(@series)
		else
			save_success = @event.update_attributes(params[:event])
		end
		
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
		if @series
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
		@series = @event.event_series
		if @series
			@event.period = @series.period
			@event.end_date = @series.end_date
		end
	end

	#setup for form - dropdowns, etc
	def form_setup
		@locations = Location.active.map { |location| [location.name, location.id] }
		@employees = Person.active.employees.map { |person| [person.full_name, person.id] }
		@pieces = Piece.all.map { |piece| [piece.name_w_choreographer, piece.id] }
	end
	
	def show_warnings
		@event.warnings.each do |key, msg|
			flash[:warning] = msg
		end
	end
	
	def add_series_errors_to_event((series))
		series.errors.each do |attrib, msg|
			@event.errors.add(attrib, msg)
		end
	end
	
	def readable_type
		type = @event.type || params[:event][:event_type]
		type.underscore.humanize.titleize
	end
	
	def get_update_mode(commit_text)
		case commit_text
			when "All"
				return :all
			when "All Future Events"
				:future
			else 	#Only This Event
				:single
		end
	end
end
