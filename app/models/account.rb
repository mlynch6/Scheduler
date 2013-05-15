# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  name       :string(100)      not null
#  time_zone  :string(100)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Account < ActiveRecord::Base
  attr_accessible :name, :time_zone
  attr_accessible :addresses_attributes, :phones_attributes, :employees_attributes
  
  has_many :addresses, :as => :addressable, dependent: :destroy
  accepts_nested_attributes_for :addresses
  has_many :phones, :as => :phoneable, dependent: :destroy
  accepts_nested_attributes_for :phones
  has_many :employees, dependent: :destroy
  accepts_nested_attributes_for :employees
  
  has_one :agma_profile, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :pieces, dependent: :destroy
  has_many :scenes, dependent: :destroy
  has_many :characters, dependent: :destroy
  has_many :events, dependent: :destroy
  
  after_create :create_profile
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :time_zone,	presence: true, length: { maximum: 100 }, inclusion: { in: ActiveSupport::TimeZone.zones_map(&:name) }
  
  default_scope order: 'name ASC'
  
  def self.current_id=(id)
  	Thread.current[:account_id] = id
  end
  
  def self.current_id
  	Thread.current[:account_id]
  end
  
 protected
  
  def create_profile
		p = AgmaProfile.new
		p.account_id = id
		p.rehearsal_start_time = '9 AM'
		p.rehearsal_end_time = '6 PM'
		p.rehearsal_max_hrs_per_week = 30
		p.rehearsal_max_hrs_per_day = 6
		p.rehearsal_increment_min = 30
		p.class_break_min = 15
		p.rehearsal_break_min_per_hr = 5
		p.costume_increment_min = 15
		p.save
	end
end
