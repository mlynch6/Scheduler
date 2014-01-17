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
	
	def self.max_rehearsal_hrs_in_day_warning(date)
		#Search only Active AGMA Dancers
		contract = AgmaProfile.find_by_account_id(Account.current_id)
		if contract.present?
			dancers = self.active.where(:role => 'AGMA Dancer')
			dancers_above_max = []
			
			dancers.each do |dancer|
				#Find rehearsals for specified date
				rehearsals = dancer.events.for_daily_calendar(date).where(:events => { :type => 'Rehearsal'})
				total_min = 0
				rehearsals.each do |rehearsal|
					total_min += rehearsal.duration
				end
				dancers_above_max << dancer if (total_min/60.0) > contract.rehearsal_max_hrs_per_day
			end
			
			if dancers_above_max.any?
				overtime_list = dancers_above_max.map { |emp| emp.full_name }.join(", ")
				return "The following people are over their rehearsal limit of #{contract.rehearsal_max_hrs_per_day} hrs/day: "+overtime_list
			end
		end
	end
	
	def self.max_rehearsal_hrs_in_week_warning(date)
		#Search only Active AGMA Dancers
		contract = AgmaProfile.find_by_account_id(Account.current_id)
		if contract.present?
			dancers = self.active.where(:role => 'AGMA Dancer')
			dancers_above_max = []
			
			dancers.each do |dancer|
				#Find rehearsals for specified date
				rehearsals = dancer.events.for_week(date).where(:events => { :type => 'Rehearsal'})
				total_min = 0
				rehearsals.each do |rehearsal|
					total_min += rehearsal.duration
				end
				dancers_above_max << dancer if (total_min/60.0) > contract.rehearsal_max_hrs_per_week
			end
			
			if dancers_above_max.any?
				overtime_list = dancers_above_max.map { |emp| emp.full_name }.join(", ")
				return "The following people are over their rehearsal limit of #{contract.rehearsal_max_hrs_per_week} hrs/week: "+overtime_list
			end
		end
	end

private
	
	def check_email_for_new_registration
  	if new_registration and email.blank?
  		errors.add(:email, "can't be blank")
  	end
	end
end
