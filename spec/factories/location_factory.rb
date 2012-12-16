# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  name       :string(50)       not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :location do
		account
		sequence(:name)	{ |n| "Studio #{n}" }
  
	  factory :location_inactive do
			active 	false
		end
	end
end
