# == Schema Information
#
# Table name: scenes
#
#  id         :integer          not null, primary key
#  name       :string(100)      not null
#  order_num  :integer          not null
#  piece_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :scene do
		sequence(:name)	{ |n| "Scene #{n}" }
		sequence(:order_num)	{ |n| "#{n}" }
		piece
	end
end
