# == Schema Information
#
# Table name: appearances
#
#  id           :integer          not null, primary key
#  scene_id     :integer          not null
#  character_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
	factory :appearance do
		scene
		character
	end
end
