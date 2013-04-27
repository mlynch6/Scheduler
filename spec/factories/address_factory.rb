# == Schema Information
#
# Table name: addresses
#
#  id               :integer          not null, primary key
#  addressable_id   :integer          not null
#  addressable_type :string(255)      not null
#  addr_type        :string(30)       not null
#  addr             :string(50)       not null
#  addr2            :string(50)
#  city             :string(50)       not null
#  state            :string(2)        not null
#  zipcode          :string(5)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryGirl.define do
	factory :address do
		association :addressable, :factory => :account
		addr_type					"Home"
		addr							Faker::Address.street_address.first(50)
		city							Faker::Address.city
		state							"MA"
		zipcode						Faker::Address.zip.first(5)
		
		factory :address_employee, parent: :address do
		  association :addressable, :factory => :employee
		end
	end
end
