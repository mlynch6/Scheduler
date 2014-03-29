# == Schema Information
#
# Table name: event_series
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  period     :string(20)       not null
#  start_date :date             not null
#  end_date   :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EventSeries < ActiveRecord::Base
	REPEATS = %w[Never Daily Weekly Monthly Yearly]
  
  attr_accessible :period, :start_date, :end_date
	#Event fields
  attr_accessor :event_type, :title, :location_id, :start_time, :duration, :piece_id, :employee_ids
  attr_accessible :event_type, :title, :location_id, :start_time, :duration, :piece_id, :employee_ids

	belongs_to :account
	has_many :events, dependent: :destroy
	
	after_create :create_events_until_end

	validates :period,	presence: true, length: { maximum: 20 }, inclusion: { in: REPEATS }
	validates :start_date, presence: true, timeliness: {type: :date}
	validates :end_date, presence: true, timeliness: {type: :date, 
																										after: (lambda { :start_date }), 
																										after_message: 'must be after the Start Date' }
	validate :events_are_valid
	
	default_scope lambda { where(:account_id => Account.current_id) }
	
	def update_event(mode = :single, event, params)
		case mode.to_sym
			when :all
				update_all_events(event, params)
			when :future
				update_future_events(event, params)
			else #:single
				update_single_event(event, params)
		end
	end
	
	def destroy_event(mode = :single, event)
		case mode.to_sym
			when :all
				self.destroy
			when :future
				destroy_future_events(event)
			else #:single
				destroy_single_event(event)
		end
	end
	
private

	def events_are_valid
		e = build_event(start_date)
		e.valid?
		add_event_errors_to_series(e)
	end
	
	def add_event_errors_to_series(event)
		event.errors.each do |event_attrib, event_error|
			errors.add(event_attrib, event_error)
		end
	end

	def create_events_until_end
		myStart = string_to_date(start_date)
		myEnd = string_to_date(end_date)
	
		rp = repeat_period(period)
		st_dt = myStart
		i = 1
		
		while st_dt <= myEnd
			e = build_event(st_dt)
			if e.save
				e.update_attribute(:event_series_id, id)
			end
			
			st_dt = myStart.advance(rp => +i)
			i += 1
		end
	end
	
	def build_event(dt)
		Event.new_with_subclass(event_type,
						title: title,
						location_id: location_id,
						start_date: dt,
						start_time: start_time,
						duration: duration,
						piece_id: piece_id,
						employee_ids: employee_ids)
	end
	
	def update_single_event(event, params)
		EventSeries.transaction do	
			if event.update_attributes(params)
				event.update_attribute(:event_series_id, nil)
				update_start_end_dates_for_series
				return true
			else
				add_event_errors_to_series(event)
				raise ActiveRecord::Rollback
				return false
			end
		end
	end
	
	def update_future_events(event, params)
		EventSeries.transaction do
			#set params for future events
			params[:event_type] = event.type
			params[:title] ||= event.title
			params[:location_id] ||= event.location_id
			params[:start_time] ||= event.start_time
			params[:duration] ||= event.duration
			params[:piece_id] ||= event.piece_id
			params[:employee_ids] ||= event.employee_ids
					
			params[:period] ||= period
			params[:start_date] ||= event.start_date
			params[:end_date] ||= end_date
						
			#destroy future events & update series end_date
			events.where("start_at >= :start", { :start => event.start_at} ).destroy_all
			update_start_end_dates_for_series
					
			#Create new series with future events
			new_series = EventSeries.create(params)
			unless new_series.valid?
				new_series.errors.each do |event_attrib, event_error|
					errors.add(event_attrib, event_error)
				end
				raise ActiveRecord::Rollback
				return false
			end
			
			return true
		end
	end
	
	def update_all_events(event, params)
		EventSeries.transaction do
			update_attributes(params)
			
			#create all new events for series
			event_type = event.type
			title = params.delete(:title) || event.title
			location_id = params.delete(:location_id) || event.location_id
			start_time = params.delete(:start_time) || event.start_time
			duration = params.delete(:duration) || event.duration
			piece_id = params.delete(:piece_id) || event.piece_id
			employee_ids = params.delete(:employee_ids) || event.employee_ids
				
			if valid?
				events.destroy_all
				create_events_until_end
				return true
			else
				raise ActiveRecord::Rollback
				return false
			end
		end
	end
	
	def destroy_single_event(event)
		EventSeries.transaction do
			if event.destroy
				update_start_end_dates_for_series
				return true
			else
				raise ActiveRecord::Rollback
				return false
			end
		end
	end
	
	def destroy_future_events(event)
		EventSeries.transaction do
			events.where("start_at >= :start", { :start => event.start_at} ).destroy_all
			if update_attribute(:end_date, events.last.start_date)
				return true
			else
				raise ActiveRecord::Rollback
				return false
			end
		end
	end
	
	def update_start_end_dates_for_series
		#Update Series Start/End Date if necessary
		first_event = events.first
		update_attribute(:start_date, first_event.start_date) if start_date != first_event.start_date
		last_event = events.last
		update_attribute(:end_date, last_event.start_date) if end_date != last_event.start_date
	end
	
	def repeat_period(period)
		case period
			when 'Daily'
				rp = :days
			when 'Weekly'
				rp = :weeks
			when 'Monthly'
				rp = :months
			when 'Yearly'
				rp = :years
		end
		
		return rp
	end
	
	def string_to_date(str, format="%m/%d/%Y")
		(str.kind_of? String) ? Date.strptime(str, format) : str
	end
end
