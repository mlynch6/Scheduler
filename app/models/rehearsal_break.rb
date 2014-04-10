# == Schema Information
#
# Table name: rehearsal_breaks
#
#  id               :integer          not null, primary key
#  agma_contract_id :integer          not null
#  break_min        :integer          not null
#  duration_min     :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class RehearsalBreak < ActiveRecord::Base
	attr_accessible :break_min, :duration_min
  
	belongs_to :agma_contract
  
	validates :break_min,	presence: true,
								:numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :duration_min,	:presence => true, 
								:numericality => { :only_integer => true, :greater_than => 0 },
								:uniqueness => { scope: :agma_contract_id }
	validate :break_less_than_duration
  
	default_scope lambda { order('duration_min ASC') }

private

	def break_less_than_duration
		if break_min.present? && duration_min.present? && break_min >= duration_min
			errors.add(:break_min, "must be less than duration")
		end
	end
end
