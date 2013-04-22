# == Schema Information
#
# Table name: characters
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  piece_id   :integer          not null
#  name       :string(30)       not null
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :character do
		account
		piece
		sequence(:name)	{ |n| "Character #{n}" }
	end
end
