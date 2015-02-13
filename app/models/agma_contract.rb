# == Schema Information
#
# Table name: agma_contracts
#
#  id                         :integer          not null, primary key
#  account_id                 :integer          not null
#  rehearsal_start_min        :integer
#  rehearsal_end_min          :integer
#  rehearsal_max_hrs_per_week :integer
#  rehearsal_max_hrs_per_day  :integer
#  rehearsal_increment_min    :integer
#  class_break_min            :integer
#  costume_increment_min      :integer
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
	
  validates :account_id, :uniqueness => true
  validates :rehearsal_start_min,	allow_blank: true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 1440 }
  validates :rehearsal_end_min,	allow_blank: true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 1440 }
  validate :rehearsal_end_cannot_be_before_rehearsal_start
  validates :rehearsal_max_hrs_per_week, allow_blank: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 168 }
  validates :rehearsal_max_hrs_per_day,	allow_blank: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 24 }
  validates :rehearsal_increment_min,	allow_blank: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 144 }
  validates :class_break_min,	allow_blank: true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 144 }
  validates :costume_increment_min,	allow_blank: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 144 }
	validates :demo_max_duration, allow_blank: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than => 1440 }
	validates :demo_max_num_per_day, allow_blank: true, :numericality => { :only_integer => true, :greater_than => 0 }
  
  default_scope lambda { where(:account_id => Account.current_id) }
  
  def rehearsal_start_time
		min_to_formatted_time(rehearsal_start_min) if rehearsal_start_min.present?
	end
	
	def rehearsal_end_time
		min_to_formatted_time(rehearsal_end_min) if rehearsal_end_min.present?
	end
	
private
	def rehearsal_end_cannot_be_before_rehearsal_start
    if rehearsal_end_min.present? && rehearsal_start_min.present? && (rehearsal_end_min <= rehearsal_start_min)
			errors.add(:rehearsal_end_min, "can't be before the Rehearsal Start")
	  end
  end
end
