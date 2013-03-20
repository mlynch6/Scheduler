# == Schema Information
#
# Table name: agma_profiles
#
#  id                         :integer          not null, primary key
#  account_id                 :integer          not null
#  rehearsal_start            :time             not null
#  rehearsal_end              :time             not null
#  rehearsal_max_hrs_per_week :integer          not null
#  rehearsal_max_hrs_per_day  :integer          not null
#  rehearsal_increment_min    :integer          not null
#  class_break_min            :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class AgmaProfile < ActiveRecord::Base
  attr_accessible :rehearsal_start_time, :rehearsal_end_time, :rehearsal_max_hrs_per_week, :rehearsal_max_hrs_per_day, :rehearsal_increment_min, :class_break_min
  
  belongs_to :account
  
  attr_writer :rehearsal_start_time, :rehearsal_end_time
  before_validation :save_rehearsal_start, :if => "@rehearsal_start_time.present?"
	before_validation :save_rehearsal_end, :if => "@rehearsal_end_time.present?"
	
  validates :account_id, :uniqueness => true
  validates_time :rehearsal_start
  validates_time :rehearsal_end, :after => :rehearsal_start, :after_message => "must be after Rehearsal Start"
  validates :rehearsal_max_hrs_per_week, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 168 }
  validates :rehearsal_max_hrs_per_day, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 24 }
  validates :rehearsal_increment_min, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 144 }
  validates :class_break_min, :numericality => { :only_integer => true, :greater_than => 0, :less_than_or_equal_to => 144 }
  
  default_scope lambda { where(:account_id => Account.current_id) }
  
  def rehearsal_start_time
		@rehearsal_start_time || rehearsal_start.try(:to_s, :hr12)
	end
	
	def rehearsal_end_time
		@rehearsal_end_time || rehearsal_end.try(:to_s, :hr12)
	end
	
	protected
	
	def save_rehearsal_start
		self.rehearsal_start = @rehearsal_start_time
	rescue ArgumentError
		errors.add :rehearsal_start_time, "cannot be parsed"
	end
	
	def save_rehearsal_end
		self.rehearsal_end = @rehearsal_end_time
	rescue ArgumentError
		errors.add :rehearsal_end_time, "cannot be parsed"
	end
end
