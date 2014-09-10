class SignupForm
	extend ActiveModel::Naming
	include ActiveModel::Conversion
	include ActiveModel::Validations
	
	attr_accessor :name, :time_zone, :phone_num, :addr, :addr2, :city, :state, :zipcode
	attr_accessor :first_name, :last_name, :email, :job_title
	attr_accessor :username, :password, :password_confirmation
	attr_accessor :current_subscription_plan_id
	attr_accessor :stripe_card_token, :card_number, :card_month, :card_year, :card_code
	
	delegate :name, :time_zone, :current_subscription_plan_id, :stripe_card_token, to: :account
	delegate :phone_num, to: :phone
	delegate :addr, :addr2, :city, :state, :zipcode, to: :address
	delegate :first_name, :last_name, :email, to: :person
	delegate :job_title, to: :employee
	delegate :username, :password, :password_confirmation, to: :user
	
	validate :validate_account
	validate :validate_phone
	validate :validate_address
	validate :validate_employee
	validate :validate_person
	validates :email,	presence: true
	validate :validate_user
	
	def account
		@account ||= Account.new
	end
	
	def phone
		@phone ||= account.phones.build(phone_type: 'Work', primary: true)
	end
	
	def address
		@address ||= account.addresses.build(addr_type: 'Work')
	end
	
	def person
		@person ||= account.people.build { |p| p.profile = employee }
	end
	
	def employee
		@employee ||= Employee.new(job_title: 'Artistic Director') { |e| e.account = account}
	end
	
	def user
		@user ||= account.users.build do |user|
			user.person = person
			#role = Dropdown.of_type('UserRole').find_by_name('Administrator')
		end
	end
	
	def submit(params)
		account.attributes = params.slice(:name, :time_zone, :current_subscription_plan_id, :stripe_card_token)
		phone.attributes = params.slice(:phone_num)
		address.attributes = params.slice(:addr, :addr2, :city, :state, :zipcode)
		person.attributes = params.slice(:first_name, :last_name, :email)
		employee.attributes = params.slice(:job_title)
		user.attributes = params.slice(:username, :password, :password_confirmation)
		
		if valid?
			account.save_with_payment
			true
		else
			errors.delete(:phones)
			errors.delete(:addresses)
			errors.delete(:people)
			errors.delete(:users)
			errors.delete(:password_digest)
			false
		end
	end
	
	def self.model_name
	  ActiveModel::Name.new(self, nil, 'Account')
	end
	
	def persisted?
		false
	end

private
	def validate_account
		account.errors.each { |field, msg| errors.add field, msg } unless account.valid?
	end
	
	def validate_phone
		phone.errors.each { |field, msg| errors.add field, msg } unless phone.valid?
	end
	
	def validate_address
		address.errors.each { |field, msg| errors.add field, msg } unless address.valid?
	end
	
	def validate_employee
		employee.errors.each { |field, msg| errors.add field, msg } unless employee.valid?
	end
	
	def validate_person
		person.errors.each { |field, msg| errors.add field, msg } unless person.valid?
	end
	
	def validate_user
		user.errors.each { |field, msg| errors.add field, msg } unless user.valid?
	end
end