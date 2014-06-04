class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
	# Based on  potenza / bootstrap_form
	# Bootstrap 3
	# Available Fields: text_field, select, time_zone_select, telephone_field, phone_field, password_field
	#		email_field, number_field, check_box, radio_button
	#		date_field, time_field, currency_field, static_control, submit, submit_primary

	FORM_HELPERS = %w{text_field select time_zone_select telephone_field phone_field password_field email_field number_field} 
	#TBD: text_area file_field url_field collection_select date_select time_select datetime_select

	DEFAULT_LABEL_WIDTH = 'col-md-3'
	DEFAULT_FIELD_WIDTH = 'col-md-9'
	DEFAULT_SUBMIT_OFFSET = 'col-md-offset-3'

	delegate :content_tag, :text_field_tag, to: :@template
	alias par_text_field text_field
	
	FORM_HELPERS.each do |method_name|
		define_method(method_name) do |name, *args|
			normalize_args!(method_name, args)
			args = set_default_options(method_name, *args)
			options = args.extract_options!.symbolize_keys!
		
			label = options.delete(:label)
			label_class = 'sr-only' if options.delete(:hide_label)
			label_required = options.delete(:required)
			field_size = options.delete(:field_size)
			help = options.delete(:help)
				
			form_group(name, label: { text: label, class: label_class, required: label_required }, field_size: field_size, help: help) do
				options[:class] = "form-control #{options[:class]}".rstrip
				args << options.except(:prepend, :append)
				
				input = super(name, *args)
				prepend_and_append_input(input, options[:prepend], options[:append])
			end
		end
	end
	
	def date_field(name, *args)
	  args = set_default_options('date_field', *args)
		
		text_field(name, *args)
	end
	
	def time_field(name, *args)
	  args = set_default_options('time_field', *args)
		
		text_field(name, *args)
	end
	
	def currency_field(name, *args)
	  args = set_default_options('currency_field', *args)
		
		number_field(name, *args)
	end
	
	def check_box(name, options = {}, checked_value = '1', unchecked_value = '0')
		options = options.symbolize_keys!
		
		html = super(name, options.except(:label, :help, :inline, :checkbox_only, :checkbox_as_row), checked_value, unchecked_value)
			
		if options[:inline]
			html << ' ' + (options[:label] || object.class.human_attribute_name(name) || name.to_s.humanize)
			label(name, html, class: 'checkbox-inline')
		elsif options[:checkbox_only]
			super(name, options.except(:label, :help, :inline, :checkbox_only), checked_value, unchecked_value)
		elsif options[:checkbox_as_row]
			content_tag :div, class: 'form-group' do
			  label(name, class: 'col-md-3 control-label') + content_tag(:div, html, class: 'col-md-9')
			end
		else
			html << ' ' + (options[:label] || object.class.human_attribute_name(name) || name.to_s.humanize)
			content_tag(:div, class: 'checkbox') do
				label(name, html)
			end
		end
	end
	
	def radio_button(name, value, *args)
		options = args.extract_options!.symbolize_keys!
		args << options.except(:label, :help, :inline)

		html = super(name, value, *args) + " " + options[:label]

		css = "radio"
		css << "-inline" if options[:inline]
		label(name, html, class: css, for: nil)
	end

	def static_control(name, options = {}, &block)
		label = options.delete(:label)
		label_class = 'sr-only' if options.delete(:hide_label)
		field_size = options.delete(:field_size)
		help = options.delete(:help)

		html = if block_given?
        yield
      else
        object.send(name)
      end

		form_group(name, label: { text: label, class: label_class }, field_size: field_size, help: help) do
			content_tag(:p, html, class: 'form-control-static')
		end
	end

	def submit(name = nil, options = {})		
		options.merge! class: 'btn btn-default' unless options.has_key? :class
		super(name, options)
	end
	
	def submit_primary(name = nil, options = {})		
		options.merge! class: 'btn btn-primary'
		submit(name, options)
	end

	def error_messages
		klass = options[:class] || 'alert alert-danger'
			
    if object.respond_to?(:errors) && object.errors.full_messages.any?
      content_tag(:div, :class => klass) do
        content_tag(:strong, content_tag(:span, nil, class: 'glyphicon glyphicon-exclamation-sign')+" Please correct the following errors:") +
        content_tag(:ul) do
          object.errors.full_messages.map do |msg|
            content_tag(:li, msg)
          end.join.html_safe
        end
      end
    end
	end
	
	def form_group(name = nil, options = {}, &block)
		options[:class] = 'form-group'
		options[:class] << ' has-error' if has_error?(name)
		field_width = options.delete(:field_size) || DEFAULT_FIELD_WIDTH

		html = content_tag(:div, yield, class: field_width)
		html << generate_help(name, options[:help])

		content_tag(:div, options.except(:label, :help)) do
			"#{generate_label(name, options[:label])} #{html}".html_safe
		end
	end
	
	def submit_group(&block)
		submit_offset = DEFAULT_SUBMIT_OFFSET
		submit_width = DEFAULT_FIELD_WIDTH

		content_tag(:div, class: 'form-group') do 
			content_tag(:div, class: "#{submit_offset} #{submit_width}") do
				yield
			end
		end
	end

	def generate_label(name, options)
		label_width = DEFAULT_LABEL_WIDTH
		
		if options
			required = object.class.validators_on(name).any? { |v| v.kind_of? ActiveModel::Validations::PresenceValidator }
			required = required || options[:required] if options.has_key? :required
			required_class = required ? "required" : ""
			options[:class] = "#{options[:class]} #{label_width} control-label #{required_class}".lstrip
			label(name, options[:text], options.except(:text))
		else
			# no label: create an empty one to keep proper form alignment
			content_tag(:label, "", class: label_width)
		end
	end
private

	def normalize_args!(method_name, args)
		if method_name == "select"
			args << {} while args.length < 3
		elsif method_name == "collection_select"
			args << {} while args.length < 5
		elsif method_name =~ /_select/
			args << {} while args.length < 2
		end
	end
    
	def has_error?(name)
		object.respond_to?(:errors) && !(name.nil? || object.errors[name].empty?)
	end
	
	def set_default_options(method_name, *args)
		options = args.extract_options!.symbolize_keys!
		
		options = case method_name
			when 'time_zone_select' then {:field_size => 'col-md-5'}.merge(options)
			when 'date_field' then {:class => 'date-select', :field_size => 'col-md-4', :placeholder => 'MM/DD/YYYY', :prepend => content_tag(:span, nil, class: 'glyphicon glyphicon-calendar')}.merge(options)
			when 'time_field' then {:field_size => 'col-md-4', :placeholder => 'HH:MM AM/PM', :prepend => content_tag(:span, nil, class: 'glyphicon glyphicon-time')}.merge(options)
			when 'telephone_field' then {:field_size => 'col-md-4', :placeholder => 'xxx-xxx-xxxx', :prepend => content_tag(:span, nil, class: 'glyphicon glyphicon-phone-alt')}.merge(options)
			when 'phone_field' then {:field_size => 'col-md-4', :placeholder => 'xxx-xxx-xxxx', :prepend => content_tag(:span, nil, class: 'glyphicon glyphicon-phone-alt')}.merge(options)
			when 'password_field' then {:prepend => content_tag(:span, nil, class: 'glyphicon glyphicon-lock')}.merge(options)
			when 'email_field' then  {:prepend => '@'}.merge(options)
			when 'currency_field' then {:field_size => 'col-md-3', :prepend => content_tag(:span, nil, class: 'glyphicon glyphicon-usd')}.merge(options)
			else options
		end
	  
	  args << options
	end
	
	def generate_help(name, help_text)
		content_tag(:span, help_text, class: 'help-block muted') if help_text
	end
	
	def prepend_and_append_input(input, prepend, append)
		input = content_tag(:span, prepend, class: 'input-group-addon') + input if prepend
		input << content_tag(:span, append, class: 'input-group-addon') if append
		input = content_tag(:div, input, class: 'input-group') if prepend || append
		input
	end
end