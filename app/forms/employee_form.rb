class EmployeeForm
	extend ActiveModel::Naming
	include ActiveModel::Conversion
	include ActiveModel::Validations
	
	attr_accessor :first_name, :middle_name, :last_name, :suffix, :gender, :birth_date, :email
	attr_accessor :job_title, :employee_num, :employment_start_date, :employment_end_date, :biography
	# attr_accessor :phone_type, :phone_num
	# attr_accessor :addr_type, :addr, :addr2, :city, :state, :zipcode
	
	delegate :first_name, :middle_name, :last_name, :suffix, :gender, :birth_date, :email, :active, to: :person
	delegate :job_title, :employee_num, :employment_start_date, :employment_end_date, :biography, to: :employee
	# delegate :phone_type, :phone_num, to: :phone
	# delegate :addr_type, :addr, :addr2, :city, :state, :zipcode, to: :address
	
	validate :validate_person
	validate :validate_employee
	# validate :validate_phone
	# validate :validate_address
	
	def initialize(form_employee = Employee.new)
		@employee = form_employee
		@person = @employee.person
	end
	
	def employee
		@employee
	end
	
	def person
		@person ||= employee.build_person
	end
	
	# def phone
	# 	@phone ||= employee.phones.build(phone_type: 'Home', primary: true)
	# end
	# 
	# def address
	# 	@address ||= employee.addresses.build(addr_type: 'Home')
	# end
	
	def submit(params)
		employee.attributes = params.slice(:job_title, :employee_num, :employment_start_date, :employment_end_date, :biography)
		person.attributes = params.slice(:first_name, :middle_name, :last_name, :suffix, :gender, :birth_date, :email, :active)
		# phone.attributes = params.slice(:phone_type, :phone_num)
		# address.attributes = params.slice(:addr_type, :addr, :addr2, :city, :state, :zipcode)
		
		if valid?
			Employee.transaction do
				employee.save!
				person.save!
			end
			true
		else
			# errors.delete(:phones)
			# errors.delete(:addresses)
			false
		end
	end
	
	def self.model_name
	  ActiveModel::Name.new(self, nil, 'Employee')
	end
	
	def persisted?
		false
	end

private
	def validate_person
		person.errors.each { |field, msg| errors.add field, msg } unless person.valid?
	end
	
	def validate_employee
		employee.errors.each { |field, msg| errors.add field, msg } unless employee.valid?
	end

	# def validate_phone
	# 	phone.errors.each { |field, msg| errors.add field, msg } unless phone.valid?
	# end
	# 
	# def validate_address
	# 	address.errors.each { |field, msg| errors.add field, msg } unless address.valid?
	# end
end