class PhoneValidator < ActiveModel::EachValidator
	def validate_each(record, attribute, value)
		unless value =~ /\A[0-9]{3}[-. ]?[0-9]{3}[-. ]?[0-9]{4}\z/i
      record.errors[attribute] << (options[:message] || "is an invalid phone number")
    end
  end
end