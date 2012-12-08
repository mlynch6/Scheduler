# == Schema Information
#
# Table name: employees
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  first_name :string(30)       not null
#  last_name  :string(30)       not null
#  active     :boolean          default(TRUE), not null
#  job_title  :string(50)
#  email      :string(50)
#  phone      :string(13)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :employee do
		account
		first_name		Faker::Name.first_name
		last_name			Faker::Name.last_name
		#job_title			Faker::Name.title
		#email					Faker::Internet.free_email
	 	#phone 				Faker::PhoneNumber.phone_number
	end
end
