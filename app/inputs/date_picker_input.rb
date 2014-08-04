class DatePickerInput < SimpleForm::Inputs::StringInput
	def input
		input_html_options[:placeholder] = 'mm/dd/yyyy'
		
		template.content_tag :div, class: 'input-group' do
			template.content_tag(:span, template.content_tag(:span, nil, class: 'glyphicon glyphicon-calendar'), class: 'input-group-addon') +
			@builder.text_field(attribute_name, input_html_options)
		end
	end
end