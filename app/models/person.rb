# == Schema Information
#
# Table name: people
#
#  id           :integer          not null, primary key
#  account_id   :integer          not null
#  profile_id   :integer          not null
#  profile_type :string(50)       not null
#  first_name   :string(30)       not null
#  middle_name  :string(30)
#  last_name    :string(30)       not null
#  suffix       :string(10)
#  gender       :string(10)
#  birth_date   :date
#  email        :string(50)
#  active       :boolean          default(TRUE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Person < ActiveRecord::Base
  GENDERS = %w[Female Male]
	
	attr_accessible :first_name, :middle_name, :last_name, :suffix
	attr_accessible :gender, :birth_date, :email, :active
	
	belongs_to :account
	belongs_to :profile, :polymorphic => true
	has_one :user, dependent: :destroy
  has_many :addresses, :as => :addressable, dependent: :destroy
  has_many :phones, :as => :phoneable, dependent: :destroy
	has_many :invitations, dependent: :destroy
  has_many :events, through: :invitations
	has_many :castings, inverse_of: :person, dependent: :nullify
	
	validates :first_name,	presence: true, length: { maximum: 30 }
	validates :middle_name,	length: { maximum: 30 }
	validates :last_name,	presence: true, length: { maximum: 30 }
	validates :suffix, length: { maximum: 10 }
	validates :gender, allow_blank: true, :inclusion => { :in => GENDERS }
	validates :birth_date, allow_blank: true, timeliness: { type: :date }
	validates :email, allow_blank: true, email: true, length: { maximum: 50 }
	validates :active, :inclusion => { :in => [true, false] }
	
	default_scope lambda { order('last_name ASC, first_name ASC').where(:account_id => Account.current_id) }
  scope :active, where(:active => true)
	scope :inactive, where(:active => false)
	scope :employees, joins("INNER JOIN employees ON people.profile_id = employees.id").where(:profile_type => 'Employee')
	scope :agma_members, employees.where(:employees => { role: 'AGMA Dancer' })
	
	def name
		if suffix.present? && middle_name.present?
			"#{last_name} #{suffix}, #{first_name} #{middle_name}"
		elsif suffix.present?
			"#{last_name} #{suffix}, #{first_name}"
		elsif middle_name.present?
			"#{last_name}, #{first_name} #{middle_name}"
		else
			"#{last_name}, #{first_name}"
		end
	end
	
	def full_name
		if suffix.present? && middle_name.present?
			"#{first_name} #{middle_name} #{last_name} #{suffix}"
		elsif suffix.present?
			"#{first_name} #{last_name} #{suffix}"
		elsif middle_name.present?
			"#{first_name} #{middle_name} #{last_name}"
		else
			"#{first_name} #{last_name}"
		end
	end
	
	def status
		self.active? ? "Active" : "Inactive"
	end
	
	def activate
		self.update_attribute(:active, true)
	end

	def inactivate
		self.update_attribute(:active, false)
	end
end
