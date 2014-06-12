# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  account_id             :integer          not null
#  employee_id            :integer          not null
#  username               :string(20)       not null
#  password_digest        :string(255)      not null
#  role                   :string(20)       not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  password_reset_token   :string(50)
#  password_reset_sent_at :datetime
#

class User < ActiveRecord::Base
  has_secure_password
	
  attr_accessible :employee_id, :username, :password, :password_confirmation
  attr_accessor :new_registration
  
  belongs_to :account
  belongs_to :employee
  
  validates :employee_id,	presence: true, unless: :new_account_registration?
  validates :username,	presence: true, length: { in: 6..20 }, uniqueness: { case_sensitive: false }
  validates :role,	presence: true, length: { maximum: 20 }
	validates :password, presence: true, :on => :create
  validates :password_confirmation, presence: true, :on => :create
  
  before_validation(:on => :create) do
    self.role ||= "Employee"
  end
  
  before_save { self.username.downcase! }
  
  default_scope lambda { where(:account_id => Account.current_id).order('username ASC') }
  
  def set_admin_role
  	self.update_attribute(:role, "Administrator")
	end
	
	def superadmin?
  	self.role == "Super Administrator"
	end
	
	def send_password_reset_email
		generate_token(:password_reset_token)
		self.password_reset_sent_at = Time.zone.now
		save!
		UserMailer.password_reset(self).deliver
	end

private
	def new_account_registration?
		new_registration
	end
	
	def generate_token(column)
		begin
			self[column] = SecureRandom.urlsafe_base64(20)
		end while User.unscoped.exists?(column => self[column])
	end
end
