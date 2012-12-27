module ApplicationHelper

	#Returns a base title with an optional page title 
	def full_title(page_title)
		base_title = "Scheduler"
		if page_title.empty?
			base_title
		else
			"#{base_title} | #{page_title}"
		end
	end
	
	#Returns HTML for a bootstrap icon followed by text
	def icon_with_text(text, icon)
		content_tag(:i, "", :class => "icon-#{icon}")+" "+text
	end
	
	#Returns 'Active' if true, 'Inactive' if false
	def active_bool_to_text(activeFlag)
		if activeFlag
			"Active"
		else
			"Inactive"
		end
	end
	
	#Formats date throughout Application
	# %d-%m-%Y				=>	08-01-2012
	# %-d-%-m-%Y			=>	8-2-2012
	# %v OR %e-%b-%Y	=>	25-Aug-2012
	def formatted_date(d, format="%v")
		Date.strptime(d, '%Y-%m-%d').strftime(format)
	end

end
