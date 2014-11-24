module ScheduleHelper
	def min_to_words(total_min)
		hrs = total_min / 60
		min = total_min % 60
		out = (hrs == 0) ? "" : pluralize(hrs, "hour")+ " "
		out += (min == 0) ? "" : pluralize(min, "minute")
		
		out.strip
	end
	
	def name_or_tbd(resource)
		resource ? resource.name : 'TBD'
	end
end