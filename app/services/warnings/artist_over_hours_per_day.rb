module Warnings
	class ArtistOverHoursPerDay
		include ActionView::Helpers::TextHelper
		
	  def initialize(myStartDate)
			@start_date = var_to_date(myStartDate)
			
			get_over_rehearsed_artists
	  end

	  def start_date
			@start_date
		end

	  def artists
			@overworked_artists || Array.new
		end

		def messages
			out = Array.new
			artists.each do |artist|
				overage = artist.worked_min.to_i - max_hours_per_day*60
				out << "#{artist.full_name} is over the maximum rehearsal allowance of #{max_hours_per_day} hrs/day by #{min_to_words(overage)}"
			end
			
			out if out.present?
		end

	private
		def get_over_rehearsed_artists
			if contract && max_hours_per_day.present?
				max_min_per_day = max_hours_per_day * 60
				
				people = Person.agma_members.joins(:events).scoped
				events = Event.where(schedulable_type: 'Rehearsal').for_day(start_date).reorder(nil).scoped
				people = people.merge(events)
				@overworked_artists = people.select("people.*, sum(DATE_PART('day', events.end_at-events.start_at)*24 + DATE_PART('hour', events.end_at-events.start_at)*60 + DATE_PART('minute', events.end_at-events.start_at)) as worked_min").group("people.id").having("sum(DATE_PART('day', events.end_at-events.start_at)*24 + DATE_PART('hour', events.end_at-events.start_at)*60 + DATE_PART('minute', events.end_at-events.start_at)) > :max_min_per_day", max_min_per_day: max_min_per_day)
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
		
		def min_to_words(total_min)
			hrs = total_min / 60
			min = total_min % 60
			out = (hrs == 0) ? "" : pluralize(hrs, "hour")+ " "
			out += (min == 0) ? "" : pluralize(min, "minute")
			
			out.strip
		end
	
		def contract
			@contract ||= AgmaContract.first
		end
		
		def max_hours_per_day
			contract.rehearsal_max_hrs_per_day
		end
	end
end

