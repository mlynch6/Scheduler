class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
	delegate :content_tag, :text_field_tag, to: :@template
	alias par_text_field text_field
	
	%w[text_field select password_field time_zone_select].each do |method_name|
		define_method(method_name) do |name, *args|
			content_tag :div, class: "control-group" do
				field_label(name, *args) + 
				(content_tag :div, :class => "controls" do
					super(name, *args) + help_text(*args)
				end)
			end
		end
	end
	
	def text_w_add_on(name, *args)
		content_tag :div, class: "control-group" do
				field_label(name, *args) + 
				(content_tag :div, :class => "controls" do
					(content_tag :div, class: "input-append" do
						par_text_field(name, *args) + append_text(name, *args)
					end) + help_text(*args)
				end)
		end
	end
	
	def email_field(name, *args)
		content_tag :div, class: "control-group" do
			field_label(name, *args) + 
			(content_tag :div, :class => "controls" do
				(content_tag :div, class: "input-prepend" do
					(content_tag :span, class: "add-on" do
						content_tag(:i, nil, class: 'icon-envelope')
					end) + 
					par_text_field(name, *args)
				end) + help_text(*args)
			end)
		end
	end
	
	def phone_field(name, *args)
		options = args.extract_options!
	  options = {:class => 'input-small', :placeholder => 'xxx-xxx-xxxx'}.merge(options)
	  args << options
		
		content_tag :div, class: "control-group" do
			field_label(name, *args) + 
			content_tag(:div, (par_text_field(name, *args) + help_text(*args)), :class => "controls")
		end
	end
	
	def date_field(name, *args)
		options = args.extract_options!
	  options = {:class => 'input-small', :placeholder => 'mm/dd/yyyy'}.merge(options)
	  args << options
	  
		content_tag :div, class: "control-group" do
			field_label(name, *args) + 
			(content_tag :div, :class => "controls" do
				(content_tag :div, class: "input-append" do
					par_text_field(name, *args) + 
					content_tag(:span, content_tag(:i, nil, class: 'icon-calendar'), class: "add-on")
				end) + help_text(*args)
			end)
		end
	end
	
	def time_field(name, *args)
		options = args.extract_options!
	  options = {:class => 'input-small'}.merge(options)
	  args << options
	  
		content_tag :div, class: "control-group" do
			field_label(name, *args) + 
			(content_tag :div, :class => "controls" do
				(content_tag :div, class: "input-append" do
					par_text_field(name, *args) + 
					content_tag(:span, content_tag(:i, nil, class: 'icon-time'), class: "add-on")
				end) + help_text(*args)
			end)
		end
	end
	
	def uneditable_text_field(name, value, *args)
		content_tag :div, class: "control-group" do
			field_label(name, *args) + 
			content_tag(:div, uneditable_text(value) + help_text(*args), :class => "controls")
		end
	end
	
#	<%= f.label :piece_id, :class => 'control-label' %>
#	<div class="controls">
#		<span class="uneditable-input"><%= @piece.name %></span>
#	</div>
	
	def submit(*args)
		content_tag :div, class: "form-actions" do
			super
		end
	end
	
	def error_messages
    if object.errors.full_messages.any?
      content_tag(:div, :class => "alert alert-error") do
        content_tag(:strong, "Please correct the following errors:") +
        content_tag(:ul) do
          object.errors.full_messages.map do |msg|
            content_tag(:li, msg)
          end.join.html_safe
        end
      end
    end
	end
	
private
	def field_label(name, *args)
		options = args.extract_options!
		required = object.class.validators_on(name).any? { |v| v.kind_of? ActiveModel::Validations::PresenceValidator }
		cls = required ? "control-label required" : "control-label"
		label(name, options[:label], class: cls)
	end
	
	def help_text(*args)
		options = args.extract_options!
		content_tag(:span, options[:help_text], class: "help-inline muted") if options[:help_text]
	end
	
	def append_text(name, *args)
		options = args.extract_options!
		content_tag(:span, options[:add_on], class: "add-on")
	end
	
	def uneditable_text(msg)
		content_tag(:span, msg, class: "uneditable-input")
	end
	
	def objectify_options(options)
		super.except(:label).except(:help_text).except(:add_on)
	end
end