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
	def link_w_icon(text, path, icon)
		link_text = content_tag(:i, nil, class: "icon-#{icon}")+text
		content_tag(:a, link_text.html_safe, :href => path)
	end
	
	#Formats date throughout Application
	# %d-%m-%Y				=>	08-01-2012
	# %-d-%-m-%Y			=>	8-2-2012
	# %v OR %e-%b-%Y	=>	25-Aug-2012
	def formatted_date(dt, format="%m/%d/%Y")
		Date.strptime(dt, '%Y-%m-%d').strftime(format)
	end

end
