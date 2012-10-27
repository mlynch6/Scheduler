# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  title       :string(30)       not null
#  event_type  :string(20)       not null
#  location_id :integer          not null
#  start_at    :datetime         not null
#  end_at      :datetime         not null
#  piece_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
	factory :event do
		sequence(:title)	{ |n| "Event #{n}" }
		event_type "Company Class"
		location
		start_at 1.hour.ago
		end_at 1.hour.from_now
		piece
  
	  factory :rehearsal do
			event_type "Rehearsal"
		end
		
		factory :performance do
			event_type "Performance"
		end
	end
end
