# == Schema Information
#
# Table name: employees
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  first_name :string(30)       not null
#  last_name  :string(30)       not null
#  active     :boolean          default(TRUE), not null
#  role       :string(50)       not null
#  email      :string(50)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Employee < ActiveRecord::Base
  ROLES = ["AGMA Dancer", "Artistic Director", "Ballet Master", "Choreographer", "Dancer", "Employee", "Guest Instructor", "Instructor", "Musician"]
  
  attr_accessible :first_name, :last_name, :active, :role, :email
  attr_accessible :user_attributes
  # Used to require email for a new account registration
  attr_accessor :new_registration
  
  belongs_to :account
	has_one :user, dependent: :destroy
  has_many :addresses, :as => :addressable, dependent: :destroy
  has_many :phones, :as => :phoneable, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :events, through: :invitations
  
  accepts_nested_attributes_for :user
  
  validates :first_name,	presence: true, length: { maximum: 30 }
  validates :last_name,	presence: true, length: { maximum: 30 }
  validates :active, :inclusion => { :in => [true, false] }
  validates :role,	presence: true, length: { maximum: 50 }, :inclusion => { :in => ROLES }
  validates :email, allow_blank: true, email: true, length: { maximum: 50 }
  validate :check_email_for_new_registration
  
  default_scope lambda { order('last_name ASC, first_name ASC').where(:account_id => Account.current_id) }
  scope :active, where(:active => true)
	scope :inactive, where(:active => false)
	scope :without_user, joins("left outer join users on employee_id = employees.id").where("users.employee_id IS NULL")
	
	def name
		"#{last_name}, #{first_name}"
	end
	
	def full_name
		"#{first_name} #{last_name}"
	end
	
	def activate
		self.update_attribute(:active, true)
	end
	
	def inactivate
		self.update_attribute(:active, false)
	end

private
	
	def check_email_for_new_registration
  	if new_registration and email.blank?
  		errors.add(:email, "can't be blank")
  	end
	end
end
