module CalendarHelper
	def calendar(date = Date.today, &block)
		Calendar.new(self, date, block).month_calendar
	end
	
	class Calendar < Struct.new(:view, :date, :callback)
		HEADER = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
		START_DAY = :sunday
		
		delegate :content_tag, to: :view
		delegate :link_to, to: :view
		
		def month_calendar
			content_tag :div do
				date_navigation + table
			end
		end
		
		def table
			content_tag :table, class: "cal-month" do
				header + week_rows
			end
		end
		
		def date_navigation
			content_tag :h2, class: "center" do
				previous_month + current_month + next_month
			end
		end
		
		def previous_month
			link_to "<< ", date: date.prev_month
		end
		
		def current_month
			date.strftime("%B %Y")
		end
		
		def next_month
			link_to " >>", date: date.next_month
		end
		
		def header
			content_tag :tr do
				HEADER.map { |day| content_tag :th, day }.join.html_safe
			end
		end
		
		def week_rows
			weeks.map do |week|
				content_tag :tr do
					week.map { |day| day_cell(day) }.join.html_safe
				end
			end.join.html_safe
		end
		
		def day_cell(day)
			content_tag :td, view.capture(day, &callback), class: day_classes(day)
		end
		
		def day_classes(day)
			classes = []
			classes << "today" if day == Date.today
			classes << "notmonth" if day.month != date.month
			classes.empty? ? nil : classes.join(" ")
		end
		
		def weeks
			first = date.beginning_of_month.beginning_of_week(START_DAY)
			last = date.end_of_month.end_of_week(START_DAY)
			(first..last).to_a.in_groups_of(7)
		end
	end
end