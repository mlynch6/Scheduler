# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  account_id             :integer          not null
#  employee_id            :integer          not null
#  username               :string(20)       not null
#  password_digest        :string(255)      not null
#  role                   :string(20)       not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  password_reset_token   :string(50)
#  password_reset_sent_at :datetime
#

FactoryGirl.define do
	factory :user do
		account
		employee
		sequence(:username)	{ |n| "username#{n}" }
	 	password 							"Password"
		password_confirmation	"Password"
		
		factory :admin do
			role	"Administrator"
		end
		
		factory :superadmin do
			role	"Super Administrator"
		end
	end
end
