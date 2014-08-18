# == Schema Information
#
# Table name: dropdowns
#
#  id            :integer          not null, primary key
#  dropdown_type :string(30)       not null
#  name          :string(30)       not null
#  comment       :text
#  position      :integer          not null
#  active        :boolean          default(TRUE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryGirl.define do
	factory :dropdown do
		dropdown_type		'UserRole'
		sequence(:name)	{ |n| "Dropdown #{n}" }
		
		trait :complete_record do
			comment		{ Faker::Lorem.paragraph }
		end
		
		trait :inactive do
			active				false
		end
		
		trait :address_type do
			dropdown_type		'AddressType'
		end
		
		trait :phone_type do
			dropdown_type		'PhoneType'
		end
		
		trait :user_role do
			dropdown_type		'UserRole'
		end
	end
end
