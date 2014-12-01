module Warnings
	class Report
		
	  def initialize(myStartDate, myEndDate)
			@start_date = var_to_date(myStartDate)
			@end_date = var_to_date(myEndDate)
	  end

	  def start_date
			@start_date
		end
		
	  def end_date
			@end_date
		end

	  def rehearsal_week_artist_over_hours_per_day
			out = Hash.new
			
			(start_date..end_date).to_a.each do |dt|
				warning = Warnings::ArtistOverHoursPerDay.new(dt)
				out[dt] = warning.messages if warning.messages.present?
			end
			
			out if out.present?
		end
		
		def rehearsal_week_artist_over_hours_per_week
			out = Hash.new
			
			(start_date.beginning_of_week..end_date).select{ |date| date.wday == 1 }.each do |dt|
				warning = Warnings::ArtistOverHoursPerWeek.new(dt)
				out[dt] = warning.messages if warning.messages.present?
			end
			
			out if out.present?
		end
		
	  def location_double_booked
			out = Hash.new
			
			(start_date..end_date).to_a.each do |dt|
				warning = Warnings::LocationDoubleBooked.new(dt)
				out[dt] = warning.messages if warning.messages.present?
			end
			
			out if out.present?
		end

	private
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
		
	end
end

