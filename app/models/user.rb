# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  account_id             :integer          not null
#  person_id              :integer          not null
#  username               :string(20)       not null
#  password_digest        :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  password_reset_token   :string(50)
#  password_reset_sent_at :datetime
#  superadmin             :boolean          default(FALSE), not null
#

class User < ActiveRecord::Base
  has_secure_password
	
  attr_accessible :person_id, :username, :password, :password_confirmation
  
  belongs_to :account
  belongs_to :person
	has_many :permissions, dependent: :destroy
  
  validates :username,	presence: true, length: { in: 6..20 }, uniqueness: { case_sensitive: false }
	validates :password, presence: true, confirmation: true, :on => :create
	validates :superadmin,	:inclusion => { :in => [true, false] }
  
  before_save { self.username.downcase! }
  
  default_scope lambda { where(:account_id => Account.current_id).order('username ASC') }
	
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
