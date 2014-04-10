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

FactoryGirl.define do
	factory :rehearsal_break do
		agma_contract
		break_min						5
		duration_min					60
	end
end
