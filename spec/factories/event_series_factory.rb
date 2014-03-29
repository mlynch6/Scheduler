# == Schema Information
#
# Table name: event_series
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  period     :string(20)       not null
#  start_date :date             not null
#  end_date   :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :event_series do
		account
		period						"Weekly"
		start_date				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		end_date					{ start_date + 2.months }
		#event fields
		event_type				"Event"
		sequence(:title)	{ |n| "Event #{n}" }
		location_id				1
		start_time				"9AM"
		duration					60
	end
end
