class ChosenSelectInput < SimpleForm::Inputs::CollectionSelectInput
	def input
		input_html_options[:class] = 'form-control chosen_select'
		super
	end
end