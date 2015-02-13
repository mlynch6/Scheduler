module Warnings
	class CompanyClassBreak
		include ActionView::Helpers::TextHelper
		
	  def initialize(myStartDate)
			@start_date = var_to_date(myStartDate)
			
			get_company_class_break_violations
	  end

	  def start_date
			@start_date
		end

		def messages
			@message if @message.present?
		end

	private
		def get_company_class_break_violations
			@violations = Array.new
			@message = Array.new
			
			if contract && break_min.present?
				company_classes = Event.where(schedulable_type: 'CompanyClass').for_day(start_date)
				company_classes.each do |klass|
					rehearsals = Event.where(schedulable_type: 'Rehearsal').where("(start_at <= :break_start and end_at > :break_start) OR (start_at < :break_end and end_at >= :break_end)", break_start: klass.end_at, break_end: klass.end_at+break_min*60)
					
					rehearsals.each do |rehearsal|
						@violations << rehearsal unless @violations.include?(rehearsal)
					end
					@message << "#{event_description(klass)} has the following rehearsals scheduled during the #{min_to_words(break_min)} break:\n"+@violations.map { |violation| event_description(violation) }.join("\n") if @violations.size > 0
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
		
		def break_min
			contract.class_break_min
		end
		
		def event_description(event)
			"#{event.title} ( #{event.time_range} )"
		end
		
	end
end

