# # Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
	config.wrappers :horizontal_form, tag: 'div', class: 'form-group', error_class: 'has-error' do |fg|
		fg.use :html5
		fg.use :placeholder
		fg.optional :maxlength
		fg.optional :pattern
		fg.optional :min_max
		fg.optional :readonly
		fg.use :label

		fg.wrapper tag: 'div', class: 'col-sm-6 col-md-6' do |input|
			input.use :input
			input.use :hint, wrap_with: { tag: 'p', class: 'help-block' }
		end
	end
	
	config.wrappers :checkbox, tag: 'div', class: 'form-group', error_class: 'has-error' do |fg|
		fg.use :html5
		fg.use :placeholder
		fg.optional :maxlength
		fg.optional :pattern
		fg.optional :min_max
		fg.optional :readonly
		fg.use :label

		fg.wrapper tag: 'div', class: 'col-sm-6 col-md-6' do |input|
			input.wrapper tag: 'div', class: 'checkbox' do |chk|
				chk.use :input
			end
			input.use :hint, wrap_with: { tag: 'p', class: 'help-block' }
		end
	end
	
	config.wrappers :horizontal_xsmall, tag: 'div', class: 'form-group', error_class: 'has-error' do |fg|
		fg.use :html5
		fg.use :placeholder
		fg.optional :maxlength
		fg.optional :pattern
		fg.optional :min_max
		fg.optional :readonly
		fg.use :label

		fg.wrapper tag: 'div', class: 'col-sm-1 col-md-1' do |input|
			input.use :input
		end
		fg.use :hint, wrap_with: { tag: 'p', class: 'help-block' }
	end
	
	config.wrappers :horizontal_small, tag: 'div', class: 'form-group', error_class: 'has-error' do |fg|
		fg.use :html5
		fg.use :placeholder
		fg.optional :maxlength
		fg.optional :pattern
		fg.optional :min_max
		fg.optional :readonly
		fg.use :label

		fg.wrapper tag: 'div', class: 'col-sm-2 col-md-2' do |input|
			input.use :input
		end
		fg.use :hint, wrap_with: { tag: 'p', class: 'help-block' }
	end
	
	config.wrappers :horizontal_medium, tag: 'div', class: 'form-group', error_class: 'has-error' do |fg|
		fg.use :html5
		fg.use :placeholder
		fg.optional :maxlength
		fg.optional :pattern
		fg.optional :min_max
		fg.optional :readonly
		fg.use :label

		fg.wrapper tag: 'div', class: 'col-sm-3 col-md-3' do |input|
			input.use :input
		end
		fg.use :hint, wrap_with: { tag: 'p', class: 'help-block' }
	end
	
	config.wrappers :horizontal_large, tag: 'div', class: 'form-group', error_class: 'has-error' do |fg|
		fg.use :html5
		fg.use :placeholder
		fg.optional :maxlength
		fg.optional :pattern
		fg.optional :min_max
		fg.optional :readonly
		fg.use :label

		fg.wrapper tag: 'div', class: 'col-sm-4 col-md-4' do |input|
			input.use :input
		end
		fg.use :hint, wrap_with: { tag: 'p', class: 'help-block' }
	end
end
