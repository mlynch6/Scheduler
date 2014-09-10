# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  account_id             :integer          not null
#  person_id              :integer          not null
#  username               :string(20)       not null
#  password_digest        :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  password_reset_token   :string(50)
#  password_reset_sent_at :datetime
#  superadmin             :boolean          default(FALSE), not null
#

FactoryGirl.define do
	factory :user do
		sequence(:username)	{ |n| "username#{n}" }
	 	password 							"Password"
		password_confirmation	"Password"
		
		after_build do |u|
			# association :account
			u.account = FactoryGirl.create(:account) unless u.account
			
			# association :person
			u.person = FactoryGirl.create(:person, account: u.account) unless u.person
		end
		
		trait :superadmin do
			superadmin		true
		end
	end
end
