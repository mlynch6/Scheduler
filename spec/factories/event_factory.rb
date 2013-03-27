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
	factory :event do
		type							"Event"
		account
		sequence(:title)	{ |n| "Event #{n}" }
		location
		start_date				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		start_time				"9AM"
		end_time					"10AM"
	end
	
	factory :company_class do
		account
		sequence(:title)	{ |n| "Company Class #{n}" }
		location
		start_date				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		start_time				"9AM"
		end_time					"10AM"
	end
	
	factory :rehearsal do
		account
		sequence(:title)	{ |n| "Rehearsal #{n}" }
		location
		start_date				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		start_time				"9AM"
		end_time					"10AM"
		piece
	end
end