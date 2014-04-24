module LinkHelper
	def icon_link(name, icon, *args)
		icon = content_tag(:span, nil, class: "glyphicon glyphicon-"+icon)
		create_link(name, icon, *args)
	end

	def new_link(name, *args)
		args << default_title('Add', *args)
		icon = content_tag(:span, nil, class: "glyphicon glyphicon-plus mash-green")
		create_link(name, icon, *args)
	end
	
	def edit_link(name, *args)
		args << default_title('Edit', *args)
		icon_link(name, 'pencil', *args)
	end
	
	def delete_link(name, *args)
		args << default_title('Delete', *args)
	  args << add_delete_method('Delete?', *args)
	  
		icon = content_tag(:span, nil, class: "glyphicon glyphicon-trash mash-red")
		create_link(name, icon, *args)
	end
	
	def view_link(name, *args)
		args << default_title('View', *args)
	  
		icon_link(name, 'info-sign', *args)
	end
	
	def pdf_link(name, *args)
		icon = image_tag("file_extension_pdf.png")
		create_link(name, icon, *args)
	end
	
# BUTTONS
	def new_button(name, *args)
	  args << add_class('btn btn-success', *args)
	  args << default_title('Add', *args)
	  
		icon = content_tag(:span, nil, class: "glyphicon glyphicon-plus")
		create_link(name, icon, *args)
	end
	
	def edit_button(name, *args)
		args << add_class('btn btn-default', *args)
		edit_link(name, *args)
	end
	
	def delete_button(name, *args)
		args << add_class('btn btn-danger', *args)
		args << default_title('Delete', *args)
	  args << add_delete_method('Delete?', *args)
	  
		icon = content_tag(:span, nil, class: "glyphicon glyphicon-trash")
		create_link(name, icon, *args)
	end
	
	def view_button(name, *args)
		args << add_class('btn btn-default', *args)
	  view_link(name, *args)
	end
	
	def activate_button(name, *args)
		args << add_class('btn btn-success', *args)
		args << default_title('Activate', *args)
		icon_link(name, 'thumbs-up', *args)
	end
	
	def inactivate_button(name, *args)
		args << add_class('btn btn-warning', *args)
		args << default_title('Inactivate', *args)
	  icon_link(name, 'thumbs-down', *args)
	end

	def gear_dropdown(&block)
		html = content_tag(:button, content_tag(:span, nil, class: "glyphicon glyphicon-cog"), type: "button", class: "btn btn-default btn-sm dropdown-toggle", data: {toggle: "dropdown"}, title: "Additional Actions")
		html << content_tag(:ul, class: "dropdown-menu", role: "menu") do
			yield
		end
		content_tag(:div, class: "btn-group pull-right", style: "margin-top: 10px;") do
			html
		end
	end
private

	def create_link(name, icon, *args)
		text = name.blank? ? nil : " #{name}"
		link_to icon + text, *args
	end
	
	def add_class(cls, *args)
		options = args.extract_options!
		if options.include?(:class) 
			options[:class] = "#{cls} #{options[:class]}"
		else
	  	options = {:class => cls}.merge(options)
	  end
	  
	  options
	end
	
	def add_delete_method(txt, *args)
		options = args.extract_options!
		options[:method] = :delete
		unless options.include?(:confirm) 
			options[:confirm] = txt
	  end
	  
	  options
	end
	
	def default_title(title, *args)
		options = args.extract_options!
		unless options.include?(:title) 
	  	options[:title] = title
	  end
	  
	  options
	end
end