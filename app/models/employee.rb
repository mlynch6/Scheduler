# == Schema Information
#
# Table name: employees
#
#  id                    :integer          not null, primary key
#  account_id            :integer          not null
#  role                  :string(50)       not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  employee_num          :string(20)
#  employment_start_date :date
#  employment_end_date   :date
#  biography             :text
#

class Employee < ActiveRecord::Base
  ROLES = ["AGMA Dancer", "Artistic Director", "Ballet Master", "Choreographer", "Dancer", "Employee", "Guest Instructor", "Instructor", "Musician"]
  
  attr_accessible :role, :employee_num, :employment_start_date, :employment_end_date, :biography
  
  belongs_to :account
	has_one :person, :as => :profile, dependent: :destroy
  
	delegate :first_name, :middle_name, :last_name, :suffix, :gender, :birth_date, :email, :active, :name, :full_name, :status, :addresses, :phones, :activate, :inactivate, to: :person
  
  validates :role, presence: true, length: { maximum: 50 }, :inclusion => { :in => ROLES }
	validates :employee_num, length: { maximum: 20 }
	validates :employment_start_date, allow_blank: true, timeliness: { type: :date }
	validates :employment_end_date, allow_blank: true, timeliness: { type: :date }
  
  default_scope lambda { where(:account_id => Account.current_id) }
  scope :active, joins(:person).where(people: {active: true})
	scope :inactive, joins(:person).where(people: {active: false})
end
