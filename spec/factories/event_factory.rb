# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  account_id       :integer          not null
#  schedulable_id   :integer          not null
#  schedulable_type :string(255)      not null
#  title            :string(30)       not null
#  location_id      :integer
#  start_at         :datetime         not null
#  end_at           :datetime         not null
#  comment          :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

FactoryGirl.define do
	factory :event do
		sequence(:title)	{ |n| "Event #{n}" }
		start_date				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		start_time				"9:15AM"
		duration					60
		
		after_build do |e|
			# association :account
			e.account = FactoryGirl.create(:account) unless e.account
			# association :schedulable
			e.schedulable = FactoryGirl.create(:lecture_demo, account: e.account) unless e.schedulable
		end
		
		trait :with_location do
			after_build do |e|
				e.location = FactoryGirl.create(:location, account: e.account) unless e.location
			end
		end
	end
end
