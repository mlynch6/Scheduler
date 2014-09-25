# == Schema Information
#
# Table name: employees
#
#  id                    :integer          not null, primary key
#  account_id            :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  employee_num          :string(20)
#  employment_start_date :date
#  employment_end_date   :date
#  biography             :text
#  job_title             :string(50)
#  agma_artist           :boolean          default(FALSE), not null
#

FactoryGirl.define do
	factory :employee do
		after_build do |emp|
			# association :account
			emp.account = FactoryGirl.create(:account) unless emp.account
		end
		
		trait :complete_record do
			sequence(:employee_num)	{ |n| "EmployeeNum#{n}" }
			employment_start_date		{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
			employment_end_date			{ employment_start_date + 2.year }
			biography								Faker::Lorem.paragraphs
			job_title								Faker::Name.title.first(30)
		end
		
		trait :agma_artist do
			agma_artist							true
		end
	end
end
