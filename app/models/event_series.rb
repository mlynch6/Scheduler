# == Schema Information
#
# Table name: event_series
#
#  id         :integer          not null, primary key
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

	has_many :events, dependent: :destroy
	
	after_create :create_events_until_end

	validates :period,	presence: true, length: { maximum: 20 }, inclusion: { in: REPEATS }
	validates :start_date, presence: true, timeliness: {type: :date}
	validates :end_date, presence: true, timeliness: {type: :date, 
																										after: (lambda { :start_date }), 
																										after_message: 'must be after the Start Date' }
	validate :events_are_valid, on: :create
	
	def destroy_event(mode = :single, event)
		EventSeries.transaction do
			case mode.to_sym
				when :all
					self.destroy
				when :future
					events.where("start_at >= :start", { :start => event.start_at} ).destroy_all
					update_attribute(:end_date, events.last.start_date)
				else #:single
					first_event = events.first
					last_event = events.last
					
					event.destroy
					update_attribute(:start_date, events.first.start_date) if event == first_event
					update_attribute(:end_date, events.last.start_date) if event == last_event
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
		rp = repeat_period(period)
		st_dt = start_date
		i = 1
		
		while st_dt <= end_date
			e = build_event(st_dt)
			if e.save
				e.update_attribute(:event_series_id, id)
			end
			
			st_dt = start_date.advance(rp => +i)
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
						piece_id: piece_id)
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
end
