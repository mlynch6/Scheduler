class StaticControlInput < SimpleForm::Inputs::Base
	def input
		text = options[:text]
		
		template.content_tag :p, text, class: 'form-control-static'
	end
end