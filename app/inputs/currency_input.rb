class CurrencyInput < SimpleForm::Inputs::StringInput
	def input
		template.content_tag :div, class: 'input-group' do
			template.content_tag(:span, template.content_tag(:span, nil, class: 'glyphicon glyphicon-usd'), class: 'input-group-addon') +
			super
		end
	end
end