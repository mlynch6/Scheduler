module Warnings
	class PersonDoubleBooked
		
	  def initialize(myStartDate)
			@start_date = var_to_date(myStartDate)
			
			get_double_booked_people
	  end

	  def start_date
			@start_date
		end

		def messages
			@message if @message.present?
		end

	private
		def get_double_booked_people
			@message = Array.new
			people_w_events = Person.joins(:events).merge(Event.for_day(start_date)).reorder("").uniq
			
			people_w_events.each do |person|
				@double_booked = Array.new
				events = person.events.for_day(start_date)
				events.each do |event|
					@double_booked += events.select { |event2| event != event2 && event.overlaps?(event2) }
				end
				@double_booked.sort_by! { |event| [event.start_at, event.end_at] }
				@message << "#{person.full_name} is double booked:\n"+@double_booked.uniq.map { |event| event_description(event) }.join("\n") if @double_booked.size > 0
			end
		end

		#Return a Date
		def var_to_date(myDate, format = '%m/%d/%Y')
			if myDate.kind_of? String
				Date.strptime(myDate, format)
			elsif myDate.kind_of? Time
				myDate.to_date
			else
				myDate
			end
		end
		
		def event_description(event)
			"#{event.title} ( #{event.time_range} )"
		end
	end
end

