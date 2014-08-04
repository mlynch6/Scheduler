class AppendInput < SimpleForm::Inputs::StringInput
	def input
		append_text = options[:append_text]
		
		template.content_tag :div, class: 'input-group' do
			super + 
			template.content_tag(:span, append_text, class: 'input-group-addon')
		end
	end
end