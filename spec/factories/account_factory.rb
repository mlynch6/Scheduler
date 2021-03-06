# == Schema Information
#
# Table name: accounts
#
#  id                           :integer          not null, primary key
#  name                         :string(100)      not null
#  time_zone                    :string(100)      not null
#  status                       :string(20)       not null
#  cancelled_at                 :datetime
#  stripe_customer_token        :string(100)
#  current_subscription_plan_id :integer          not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

FactoryGirl.define do
	factory :account do
		name				Faker::Company.name
		time_zone		"Pacific Time (US & Canada)"
		
		after_build do |acnt|
			acnt.current_subscription_plan = SubscriptionPlan.first unless acnt.current_subscription_plan
			acnt.current_subscription_plan = FactoryGirl.create(:subscription_plan) unless acnt.current_subscription_plan
		end
	end
end
