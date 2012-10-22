# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string(50)       not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :location do
		sequence(:name)	{ |n| "Studio #{n}" }
  
	  factory :location_inactive do
			active 	false
		end
	end
end
