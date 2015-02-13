class Reports::WarningsController < ApplicationController
	authorize_resource :warnings_report, :class => false
	helper_method :start_date, :end_date

	def show
		if params[:start_date].present?
			set_date_range
			report = Warnings::Report.new(start_date, end_date)
			@location_double_booked = report.location_double_booked
			@company_class_break_violations = report.company_class_break_violations
			@rehearsal_week_artist_over_hours_per_day = report.rehearsal_week_artist_over_hours_per_day
			@rehearsal_week_artist_over_hours_per_week = report.rehearsal_week_artist_over_hours_per_week
			
			@contract = current_user.account.agma_contract
		end
	end

private
	def set_date_range(format = '%m/%d/%Y')
		@start_date = params[:start_date].present? ? Date.strptime(params[:start_date], format) : Date.today
		@end_date = params[:end_date].present? ? Date.strptime(params[:end_date], format) : @end_date = @start_date
	end

	def start_date
		@start_date
	end

	def end_date
		@end_date
	end
end
