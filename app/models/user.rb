# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  account_id             :integer          not null
#  person_id              :integer          not null
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
	
  attr_accessible :person_id, :username, :password, :password_confirmation
  
  belongs_to :account
  belongs_to :person
  
  validates :username,	presence: true, length: { in: 6..20 }, uniqueness: { case_sensitive: false }
  validates :role,	presence: true, length: { maximum: 20 }
	validates :password, presence: true, confirmation: true, :on => :create
  
  before_validation(:on => :create) do
    self.role ||= "Employee"
  end
  
  before_save { self.username.downcase! }
  
  default_scope lambda { where(:account_id => Account.current_id).order('username ASC') }
	
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
	def generate_token(column)
		begin
			self[column] = SecureRandom.urlsafe_base64(20)
		end while User.unscoped.exists?(column => self[column])
	end
end
