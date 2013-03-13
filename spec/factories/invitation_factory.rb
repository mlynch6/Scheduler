# == Schema Information
#
# Table name: invitations
#
#  id          :integer          not null, primary key
#  event_id    :integer          not null
#  employee_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
	factory :invitation do
		event
		employee
	end
end
