# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  employee_id     :integer          not null
#  username        :string(20)       not null
#  password_digest :string(255)      not null
#  role            :string(20)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
	factory :user do
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
