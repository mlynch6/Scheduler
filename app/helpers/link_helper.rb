module LinkHelper
	def new_link(name, *args)
		options = args.extract_options!
	  options = {:title => "Add"}.merge(options) if name.blank?
	  args << options
	  
		icon = content_tag(:i, nil, class: "icon-plus")
		create_link(name, icon, *args)
	end
	
	def edit_link(name, *args)
		options = args.extract_options!
	  options = {:title => "Edit"}.merge(options) if name.blank?
	  args << options
	  
		icon = content_tag(:i, nil, class: "icon-pencil")
		create_link(name, icon, *args)
	end
	
	def delete_link(name, *args)
		options = args.extract_options!
	  options = {:method => :delete, :confirm => "Delete?"}.merge(options)
	  options = {:title => "Delete"}.merge(options) if name.blank?
	  args << options
	  
		icon = content_tag(:i, nil, class: "icon-trash")
		create_link(name, icon, *args)
	end
	
	def view_link(name, *args)
		options = args.extract_options!
	  options = {:title => "View"}.merge(options) if name.blank?
	  args << options
	  
		icon = content_tag(:i, nil, class: "icon-info-sign")
		create_link(name, icon, *args)
	end
	
	def pdf_link(name, *args)
		icon = image_tag("file_extension_pdf.png")
		create_link(name, icon, *args)
	end
	
	def excel_link(name, *args)
		icon = image_tag("file_extension_xls.png")
		create_link(name, icon, *args)
	end
	
# BUTTONS
	def new_button(name, *args)
		options = args.extract_options!
		if options.include?(:class) 
			options[:class] = "btn #{options[:class]}"
		else
	  	options = {:class => 'btn'}.merge(options)
	  end
	  options = {:title => "Add"}.merge(options) if name.blank?
	  args << options
	  
		icon = content_tag(:i, nil, class: "icon-plus")
		create_link(name, icon, *args)
	end
	
	def edit_button(name, *args)
		options = args.extract_options!
		if options.include?(:class) 
			options[:class] = "btn #{options[:class]}"
		else
	  	options = {:class => 'btn'}.merge(options)
	  end
	  options = {:title => "Edit"}.merge(options) if name.blank?
	  args << options
	  
		icon = content_tag(:i, nil, class: "icon-pencil")
		create_link(name, icon, *args)
	end
	
	def delete_button(name, *args)
		options = args.extract_options!
		if options.include?(:class) 
			options[:class] = "btn btn-danger #{options[:class]}"
		else
	  	options = {:class => 'btn btn-danger'}.merge(options)
	  end
	  options = {:method => :delete, :confirm => "Delete?"}.merge(options)
	  options = {:title => "Delete"}.merge(options) if name.blank?
	  args << options
	  
		icon = content_tag(:i, nil, class: "icon-trash")
		create_link(name, icon, *args)
	end
	
	def view_button(name, *args)
		options = args.extract_options!
		if options.include?(:class) 
			options[:class] = "btn btn-info #{options[:class]}"
		else
	  	options = {:class => 'btn btn-info'}.merge(options)
	  end
	  options = {:title => "View"}.merge(options) if name.blank?
	  args << options
	  
	  icon = content_tag(:i, nil, class: "icon-info-sign")
		create_link(name, icon, *args)
	end
	
	def activate_button(name, *args)
		options = args.extract_options!
		if options.include?(:class) 
			options[:class] = "btn btn-success #{options[:class]}"
		else
	  	options = {:class => 'btn btn-success'}.merge(options)
	  end
	  options = {:title => "Activate"}.merge(options) if name.blank?
	  args << options
	  
	  icon = content_tag(:i, nil, class: "icon-thumbs-up")
		create_link(name, icon, *args)
	end
	
	def inactivate_button(name, *args)
		options = args.extract_options!
		if options.include?(:class) 
			options[:class] = "btn btn-warning #{options[:class]}"
		else
	  	options = {:class => 'btn btn-warning'}.merge(options)
	  end
	  options = {:title => "Inactivate"}.merge(options) if name.blank?
	  args << options
	  
	  icon = content_tag(:i, nil, class: "icon-thumbs-down")
		create_link(name, icon, *args)
	end

private

	def create_link(name, icon, *args)
		text = name.blank? ? nil : " #{name}"
		link_to icon + text, *args
	end
end