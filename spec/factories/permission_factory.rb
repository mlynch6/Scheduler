# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  user_id    :integer          not null
#  role_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :permission do
		after_build do |p|
			# association :account
			p.account = FactoryGirl.create(:account) unless p.account
			# association :user
			p.user = FactoryGirl.create(:user, account: p.account) unless p.user
			# association :role
			p.role = FactoryGirl.create(:dropdown, :user_role) unless p.role
		end
	end
end