# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
#  title           :string(30)       not null
#  type            :string(20)       default("Event"), not null
#  location_id     :integer          not null
#  start_at        :datetime         not null
#  end_at          :datetime         not null
#  piece_id        :integer
#  event_series_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
	factory :event do
		account
		sequence(:title)	{ |n| "Event #{n}" }
		location
		start_date				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		start_time				"9AM"
		duration					60
	end
	
	factory :company_class do
		account
		sequence(:title)	{ |n| "Company Class #{n}" }
		location
		start_date				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		start_time				"9AM"
		duration					60
	end
	
	factory :rehearsal do
		account
		sequence(:title)	{ |n| "Rehearsal #{n}" }
		location
		start_date				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		start_time				"9AM"
		duration					60
		piece
	end
	
	factory :costume_fitting do
		account
		sequence(:title)	{ |n| "Costume Fitting #{n}" }
		location
		start_date				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		start_time				"8:30AM"
		duration					30
	end
end
