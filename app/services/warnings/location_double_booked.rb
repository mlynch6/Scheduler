module Warnings
	class LocationDoubleBooked
		
	  def initialize(myStartDate)
			@start_date = var_to_date(myStartDate)
			
			get_double_booked_locations
	  end

	  def start_date
			@start_date
		end

		def events
			out = @double_booked.sort_by! { |event| event.start_at }
			out if out.present?
		end

		def messages
			@message if @message.present?
		end

	private
		def get_double_booked_locations
			@double_booked = Array.new
			@message = Array.new
			
			events = Event.for_day(start_date).where("location_id IS NOT NULL")
			events.each do |event|
				unless @double_booked.include?(event)
					overlapping = Event.where("id <> :id", id: event.id).where(location_id: event.location_id).where("(start_at <= :start_at and end_at > :start_at) OR (start_at < :end_at and end_at >= :end_at)", start_at: event.start_at, end_at: event.end_at)
					
					@double_booked << event if overlapping.size > 0 && !@double_booked.include?(event)
				  overlapping.each do |overlapping_event|
						@double_booked << overlapping_event unless @double_booked.include?(overlapping_event)
					end
					@message << "#{event.location.name} is double booked:\n #{event_description(event)} \n"+overlapping.map { |overlapping_event| event_description(overlapping_event) }.join("\n") if overlapping.size > 0
				end
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

