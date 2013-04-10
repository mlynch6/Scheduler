# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  employee_id     :integer          not null
#  username        :string(20)       not null
#  password_digest :string(255)      not null
#  role            :string(20)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ActiveRecord::Base
  has_secure_password
	
  attr_accessible :employee_id, :username, :password, :password_confirmation
  attr_accessor :new_registration
  
  belongs_to :employee
  
  validates :employee_id,	presence: true, unless: :new_account_registration?
  validates :username,	presence: true, length: { in: 6..20 }, uniqueness: { case_sensitive: false }
  validates :role,	presence: true, length: { maximum: 20 }
  validates :password_confirmation,	presence: true
  
  before_validation(:on => :create) do
    self.role ||= "Employee"
  end
  
  before_save { self.username.downcase! }
  
  default_scope lambda { joins(:employee).where(:employees => { :account_id => Account.current_id}) }
  
  def set_admin_role
  	self.update_attribute(:role, "Administrator")
	end
	
	def superadmin?
  	self.role == "Super Administrator"
	end

private
	def new_account_registration?
		new_registration
	end
end
