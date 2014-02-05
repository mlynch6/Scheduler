# == Schema Information
#
# Table name: employees
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  first_name :string(30)       not null
#  last_name  :string(30)       not null
#  active     :boolean          default(TRUE), not null
#  role       :string(50)       not null
#  email      :string(50)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :employee do
		account
		sequence(:first_name)	{ |n| "#{Faker::Name.first_name}" }
		sequence(:last_name)	{ |n| "#{Faker::Name.last_name}" }
		role					"Employee"
		#email					Faker::Internet.free_email
	 	
	 	factory :employee_inactive do
			active 			false
		end
		
		factory :musician do
			role					"Musician"
		end
		
		factory :teacher do
			role					"Instructor"
		end
		
		factory :dancer do
			role					"AGMA Dancer"
		end
		
		factory :employee_w_addresses do
			after_create { |emp| FactoryGirl.create_list(:address_employee, 3, addressable: emp)}
		end
		
		factory :employee_w_phones do
			after_create { |emp| FactoryGirl.create_list(:phone_employee, 3, phoneable: emp)}
		end
	end
end
