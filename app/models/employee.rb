# == Schema Information
#
# Table name: employees
#
#  id                    :integer          not null, primary key
#  account_id            :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  employee_num          :string(20)
#  employment_start_date :date
#  employment_end_date   :date
#  biography             :text
#  job_title             :string(50)
#  agma_artist           :boolean          default(FALSE), not null
#

class Employee < ActiveRecord::Base
  attr_accessible :job_title, :employee_num, :employment_start_date, :employment_end_date, :biography
  
  belongs_to :account
	has_one :person, :as => :profile, dependent: :destroy
  
	delegate :first_name, :middle_name, :last_name, :suffix, :gender, :birth_date, :age, :email, :active, :name, :full_name, :status, :addresses, :phones, :activate, :inactivate, to: :person
  
	validates :employee_num, length: { maximum: 20 }
	validates :employment_start_date, allow_blank: true, timeliness: { type: :date }
	validates :employment_end_date, allow_blank: true, timeliness: { type: :date }
	validates :job_title, length: { maximum: 30 }
	validates :agma_artist,	:inclusion => { :in => [true, false] }
  
  default_scope lambda { where(:account_id => Account.current_id) }
  scope :active, joins(:person).where(people: { active: true })
	scope :inactive, joins(:person).where(people: { active: false })
	
	def self.search(query)
		#Default show all
		employees = Employee.joins(:person)
		
		if query.include?(:fname)
			employees = employees.where('first_name LIKE :q', q: "%#{query[:fname]}%")
		end
		
		if query.include?(:lname)
			employees = employees.where('last_name LIKE :q', q: "%#{query[:lname]}%")
		end
		
		if query.include?(:status) && query[:status] == "active"
			employees = employees.active
		elsif query.include?(:status) && query[:status] == "inactive"
			employees = employees.inactive
		end
		
		employees
	end
end
