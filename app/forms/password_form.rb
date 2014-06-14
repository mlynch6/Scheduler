class PasswordForm
	extend ActiveModel::Naming
	include ActiveModel::Conversion
	include ActiveModel::Validations
	
	attr_accessor :current_password, :new_password
	
	validate :verify_old_password
	validates :current_password, presence: true
	validates :new_password, presence: true, confirmation: true, length: { minimum: 6 }
	
	def initialize(user)
		@user = user
	end
	
	def submit(params)
		self.current_password = params[:current_password]
		self.new_password = params[:new_password]
		self.new_password_confirmation = params[:new_password_confirmation]
		if valid?
			@user.password = new_password
			@user.save!
			true
		else
			false
		end
	end
	
	def persisted?
		false
	end

private
	def verify_old_password
		unless @user.authenticate(current_password)
			errors.add :current_password, 'is not correct'
		end
	end
end