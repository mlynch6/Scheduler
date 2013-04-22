# == Schema Information
#
# Table name: scenes
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  piece_id   :integer          not null
#  name       :string(100)      not null
#  position   :integer          not null
#  track      :string(20)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :scene do
		account
		piece
		sequence(:name)	{ |n| "Scene #{n}" }
	end
end
