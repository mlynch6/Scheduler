# == Schema Information
#
# Table name: subscription_plans
#
#  id         :integer          not null, primary key
#  name       :string(50)       not null
#  amount     :decimal(7, 2)    not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :subscription_plan do
		sequence(:name)	{ |n| "Subscription Plan #{n}" }
		amount			15.10
	end
end
