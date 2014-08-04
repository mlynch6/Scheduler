module BootstrapHelper
	def form_actions(&block)
		content_tag :div, class: 'form-group' do
			content_tag :div, class: 'col-sm-offset-3 col-sm-9 col-md-offset-3 col-md-9' do
				yield
			end
		end
	end
	
	def show_error_messages(object)
		if object.errors.present?
			content_tag :div, class: 'alert alert-danger' do
	      content_tag(:strong, content_tag(:span, nil, class: 'glyphicon glyphicon-exclamation-sign')+" Please correct the following errors:") +
	      content_tag(:ul) do
	        object.errors.full_messages.map do |msg|
	          content_tag(:li, msg)
	        end.join.html_safe
				end
			end
		end
	end
	
	def static_control(text)
		content_tag :p, text, class: 'form-control-static'
	end
end