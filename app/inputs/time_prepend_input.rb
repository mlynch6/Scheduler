class TimePrependInput < SimpleForm::Inputs::StringInput
	def input
		template.content_tag :div, class: 'input-group' do
			template.content_tag(:span, template.content_tag(:span, nil, class: 'glyphicon glyphicon-time'), class: 'input-group-addon') +
			@builder.text_field(attribute_name, input_html_options)
		end
	end
end