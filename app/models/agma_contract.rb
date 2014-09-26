# == Schema Information
#
# Table name: agma_contracts
#
#  id                         :integer          not null, primary key
#  account_id                 :integer          not null
#  rehearsal_start_min        :integer          not null
#  rehearsal_end_min          :integer          not null
#  rehearsal_max_hrs_per_week :integer          not null
#  rehearsal_max_hrs_per_day  :integer          not null
#  rehearsal_increment_min    :integer          not null
#  class_break_min            :integer          not null
#  costume_increment_min      :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  demo_max_duration          :integer
#  demo_max_num_per_day       :integer
#

class AgmaContract < ActiveRecord::Base
	include ApplicationHelper
	
  attr_accessible :rehearsal_start_min, :rehearsal_end_min, :rehearsal_max_hrs_per_week, :rehearsal_max_hrs_per_day, :rehearsal_increment_min
  attr_accessible :class_break_min, :costume_increment_min, :demo_max_duration, :demo_max_num_per_day
  attr_accessible :rehearsal_breaks_attributes
  
  belongs_to :account
  has_many :rehearsal_breaks, inverse_of: :agma_contract, dependent: :destroy
  accepts_nested_attributes_for :rehearsal_breaks
  
  before_validation :set_defaults, on: :create
	
  validates :account_id, :uniqueness => true
  validates :rehearsal_start_min,	presence: true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 1440 }
  validates :rehearsal_end_min,	presence: true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 1440 }
  validate :rehearsal_end_cannot_be_before_rehearsal_start
  validates :rehearsal_max_hrs_per_week,	presence: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 168 }
  validates :rehearsal_max_hrs_per_day,	presence: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 24 }
  validates :rehearsal_increment_min,	presence: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 144 }
  validates :class_break_min,	presence: true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 144 }
  validates :costume_increment_min,	presence: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 144 }
	validates :demo_max_duration, allow_blank: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than => 1440 }
	validates :demo_max_num_per_day, allow_blank: true, :numericality => { :only_integer => true, :greater_than => 0 }
  
  default_scope lambda { where(:account_id => Account.current_id) }
  
  def rehearsal_start_time
		min_to_formatted_time(rehearsal_start_min)
	end
	
	def rehearsal_end_time
		min_to_formatted_time(rehearsal_end_min)
	end
	
private

  def set_defaults
		self.rehearsal_start_min = 540 if rehearsal_start_min.blank? # 9AM
		self.rehearsal_end_min = 1080 if rehearsal_end_min.blank? # 6PM
		self.rehearsal_max_hrs_per_week = 30 if rehearsal_max_hrs_per_week.blank?
		self.rehearsal_max_hrs_per_day = 6 if rehearsal_max_hrs_per_day.blank?
		self.rehearsal_increment_min = 30 if rehearsal_increment_min.blank?
		self.class_break_min = 15 if class_break_min.blank?
		self.costume_increment_min = 15 if costume_increment_min.blank?
	end
	
	def rehearsal_end_cannot_be_before_rehearsal_start
    if rehearsal_end_min.present? && rehearsal_start_min.present? && (rehearsal_end_min <= rehearsal_start_min)
			errors.add(:rehearsal_end_min, "can't be before the Rehearsal Start")
	  end
  end
end
