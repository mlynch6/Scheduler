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
#  rehearsal_break_min_per_hr :integer          not null
#  costume_increment_min      :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

FactoryGirl.define do
	factory :agma_profile do
		account
		rehearsal_start_time					"9 AM"
		rehearsal_end_time						"5 PM"
		rehearsal_max_hrs_per_week		30
		rehearsal_max_hrs_per_day			6
	 	rehearsal_increment_min 			30
	 	class_break_min								15
	end
end
