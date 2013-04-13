module DailyCalendarHelper
	def daily_calendar(date = Date.today, headers=[], &block)
		DailyCalendar.new(self, date, headers, block).calendar
	end
	
	def calculate_offset(start_at, duration)
		time_in_min = start_at.hour * 60 + start_at.min
		t = (time_in_min * 4/3) - 3
		h = (duration/60 * 80) - 4
		return 'style="top: '+t.to_s+'px; height: '+h.to_s+'px;"'
	end
	
	class DailyCalendar < Struct.new(:view, :date, :headers, :callback)
		delegate :content_tag, to: :view
		delegate :link_to, to: :view
		
		def calendar
			date_header + column_header + data_table
		end
		
		def date_header
			content_tag :h2, class: "text-center" do
				date.strftime('%A, %B %d, %Y')
			end
		end
		
		def column_header
			content_tag :table, class: "calendar cal-daily" do
				content_tag :thead do
					header_row
				end
			end
		end
		
		def header_row
			content_tag :tr do
				content_tag(:th, nil, class: "hour-column") + 
				headers.map { |name| content_tag(:th, name) }.join.html_safe
			end
		end
		
		def data_table
			content_tag :div, id: "calendar-daily" do
				content_tag :div, class: "cal-scrollable" do
					table
				end
			end
		end
		
		def table
			content_tag :table, class: "calendar cal-daily" do
				background_grid + data_grid
			end
		end
		
		def background_grid
			content_tag :tr do
				hour_grid + time_grid
			end
		end
		
		def data_grid
			content_tag :tr do
				hour_data_grid + 
				headers.map { |column_name| data_column_grid(column_name) }.join.html_safe
			end
		end
		
		def hour_grid
			content_tag :td, class: "hour-column" do
				content_tag :div, class: "grid-container" do
					content_tag :div, class: "hours-wrapper" do
						hour_headers
					end
				end
			end
		end
		
		def time_grid
			cols = headers.size
			content_tag :td, colspan: cols do
				content_tag :div, class: "grid-container" do
					content_tag :div, class: "grid-wrapper" do
						time_slots
					end
				end
			end
		end
		
		def hour_headers
			(0..23).map { |hr| 
				if hr==9
					content_tag :div, class: "hour-slot", id: "#" do
						Time.parse("#{hr}:00").to_s(:hr12)
					end
				else
					content_tag :div, class: "hour-slot" do
						Time.parse("#{hr}:00").to_s(:hr12)
					end
				end
			}.join.html_safe
		end
		
		def time_slots
			(0..23).map { |slot| 
				content_tag :div, class: "hour-slot" do
					content_tag(:div, nil, class: "time-slot") +
					content_tag(:div, nil, class: "time-slot") + 
					content_tag(:div, nil, class: "time-slot") + 
					content_tag(:div, nil, class: "time-slot hour-end")
				end
			}.join.html_safe
		end
		
		def hour_data_grid
			content_tag :td, nil, class: "hour-column"
		end
		
		def data_column_grid(column_name)
			content_tag :td do
				content_tag :div, view.capture(column_name, &callback), class: "day-container"
			end
		end
	end
end