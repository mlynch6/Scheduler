# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(30)       not null
#  piece_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :role do
		sequence(:name)	{ |n| "Role #{n}" }
		piece
	end
end
