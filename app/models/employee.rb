# == Schema Information
#
# Table name: employees
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  first_name :string(30)       not null
#  last_name  :string(30)       not null
#  active     :boolean          default(TRUE), not null
#  job_title  :string(50)
#  email      :string(50)
#  phone      :string(13)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Employee < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :active, :job_title, :email, :phone
  attr_accessible :user_attributes
  attr_accessor :new_registration
  
  belongs_to :account
  has_one :user, dependent: :destroy
  accepts_nested_attributes_for :user
  
  validates :first_name,	presence: true, length: { maximum: 30 }
  validates :last_name,	presence: true, length: { maximum: 30 }
  validates :active,	:inclusion => { :in => [true, false] }
  validates :job_title, length: { maximum: 50 }
  validates :email, allow_blank: true, email: true, length: { maximum: 50 }
  validates :email,	presence: true, :if => :new_account_registration?
  validates :phone, allow_blank: true, phone: true,	length: { maximum: 13 }
  
  default_scope order: 'employees.last_name ASC, employees.first_name ASC'
  
  # Used to require email for a new account registration
  def new_account_registration?
  	new_registration
	end
end