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
	validate :events_are_valid, on: :create
	
	default_scope lambda { where(:account_id => Account.current_id) }
	
	def update_event(mode = :single, event, params)
		EventSeries.transaction do
			case mode.to_sym
				when :all
					update_attributes(params)
					
					events.destroy_all
					
					#create all new events for series
					event_type = event.type
					title = params.delete(:title) || event.title
					location_id = params.delete(:location_id) || event.location_id
					start_time = params.delete(:start_time) || event.start_time
					duration = params.delete(:duration) || event.duration
					piece_id = params.delete(:piece_id) || event.piece_id
					employee_ids = params.delete(:employee_ids) || event.employee_ids
					
					create_events_until_end
				when :future
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
					EventSeries.create(params)
				else #:single
					event.update_attributes(params)
					event.update_attribute(:event_series_id, nil)
					update_start_end_dates_for_series
			end
		end
	end
	
	def destroy_event(mode = :single, event)
		EventSeries.transaction do
			case mode.to_sym
				when :all
					self.destroy
				when :future
					events.where("start_at >= :start", { :start => event.start_at} ).destroy_all
					update_attribute(:end_date, events.last.start_date)
				else #:single
					event.destroy
					update_start_end_dates_for_series
			end
		end
	end
	
private

	def events_are_valid
		e = build_event(start_date)
		e.valid?
		e.errors.each do |event_attrib, event_error|
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
