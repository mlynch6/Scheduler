# == Schema Information
#
# Table name: people
#
#  id           :integer          not null, primary key
#  account_id   :integer          not null
#  profile_id   :integer          not null
#  profile_type :string(50)       not null
#  first_name   :string(30)       not null
#  middle_name  :string(30)
#  last_name    :string(30)       not null
#  suffix       :string(10)
#  gender       :string(10)
#  birth_date   :date
#  email        :string(50)
#  active       :boolean          default(TRUE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
	factory :person do
		first_name		{ Faker::Name.first_name.first(30) }
		last_name			{ Faker::Name.last_name.first(30) }
		
		after_build do |per|
			# association :account
			per.account = FactoryGirl.create(:account) unless per.account
			
			# association :profile, factory: :employee
			per.profile = FactoryGirl.create(:employee, account: per.account) unless per.profile
			per.profile.account = per.account unless per.profile.account == per.account 
		end
		
		trait :complete_record do
			middle_name	{ Faker::Name.first_name.first(30) }
			suffix			{ Faker::Name.suffix.first(10) }
			gender			'Female'
			email				{ Faker::Internet.free_email.first(50) }
		end
		
		trait :active do
			active			true
		end
		
		trait :inactive do
			active			false
		end
		
		trait :agma do
			after_create do |p| 
				p.profile.agma_artist = true
				p.profile.save
			end
		end
	end
end
