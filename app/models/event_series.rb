# == Schema Information
#
# Table name: event_series
#
#  id         :integer          not null, primary key
#  period     :string(20)       not null
#  start_at   :date             not null
#  end_at     :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EventSeries < ActiveRecord::Base
	REPEATS = %w[Never Daily Weekly Monthly Yearly]
  
  attr_accessible :period, :start_at, :end_at
	#Event fields
  attr_accessor :type, :title, :location_id, :start_time, :duration, :piece_id

	has_many :events, dependent: :destroy
	
	after_create :create_events_until_end

	validates :period,	presence: true, length: { maximum: 20 }, inclusion: { in: REPEATS }
	validates :start_at, presence: true, timeliness: {type: :date}
	validates :end_at, presence: true, timeliness: {type: :date, after: (lambda { :start_at }) }
	
	validate :events_are_valid, on: :create
	
private

	def events_are_valid
		e = build_event(start_at)
		e.valid?
		e.errors.each do |event_attrib, event_error|
			errors.add(event_attrib, event_error)
		end
	end

	def create_events_until_end
		rp = repeat_period(period)
		st_dt = start_at
		i = 1
		
		while st_dt <= end_at
			e = build_event(st_dt)
			e.save
			e.update_attribute(:event_series_id, id)
			
			st_dt = start_at.advance(rp => +i)
			i += 1
		end
	end
	
	def build_event(dt)
		Event.new_with_subclass(type,
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
