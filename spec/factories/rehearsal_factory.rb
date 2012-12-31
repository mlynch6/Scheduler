# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  account_id  :integer          not null
#  title       :string(30)       not null
#  type        :string(20)       not null
#  location_id :integer          not null
#  start_at    :datetime         not null
#  end_at      :datetime         not null
#  piece_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
	factory :rehearsal do
		account
		sequence(:title)	{ |n| "Rehearsal #{n}" }
		location
		start_at 1.hour.ago
		end_at 1.hour.from_now
		piece
	end
end
