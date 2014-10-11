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
#  costume_increment_min      :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  demo_max_duration          :integer
#  demo_max_num_per_day       :integer
#

FactoryGirl.define do
	factory :agma_contract do
		account
		rehearsal_start_min					540		# 9AM
		rehearsal_end_min						1020	# 5PM
		rehearsal_max_hrs_per_week	30
		rehearsal_max_hrs_per_day		6
	 	rehearsal_increment_min 		30
	 	class_break_min							15
	 	costume_increment_min				15
		demo_max_duration						50
		demo_max_num_per_day				3
	end
end
