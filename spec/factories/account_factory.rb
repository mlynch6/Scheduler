# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  name       :string(100)      not null
#  main_phone :string(13)       not null
#  time_zone  :string(100)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :account do
		name				Faker::Company.name
	 	main_phone 	"111-222-3333" #Faker::PhoneNumber.phone_number
		time_zone		"Eastern Time (US & Canada)"
	end
end
