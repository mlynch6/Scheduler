module ApplicationHelper
	include ActionView::Helpers::NumberHelper
	
	#Returns a base title with an optional page title 
	def full_title(page_title)
		base_title = "Scheduler"
		if page_title.empty?
			base_title
		else
			"#{base_title} | #{page_title}".html_safe
		end
	end
	
	#Formats date throughout Application
	# %d-%m-%Y				=>	08-01-2012
	# %-d-%-m-%Y			=>	8-2-2012
	# %v OR %e-%b-%Y	=>	25-Aug-2012
	def formatted_date(dt, format="%m/%d/%Y")
		Date.strptime(dt, '%Y-%m-%d').strftime(format)
	end
	
	#Input: number of minutes past midnight
	#Output: formatted time
	def min_to_formatted_time(mnt)
		(Time.now.midnight + mnt.minutes).to_s(:hr12)
	end
	
	#Input: n/a
	#Output: h1 small text for All/Active/Inactive
	def header_status_text
		if params[:status] == "active"
			'Active'
		elsif params[:status] == "inactive"
			'Inactive'
		else
			'All'
		end
	end
	
	#Input: String Ex: user_role
	#Output: Titleized text: User Role
	def readable_klass(klass_name)
		klass_name.blank? ? '' : klass_name.underscore.humanize.titleize
	end
	
	def bootstrap_icon(icon_name)
		content_tag :span, nil, class: "glyphicon glyphicon-#{icon_name}"
	end
end
