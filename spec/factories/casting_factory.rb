# == Schema Information
#
# Table name: castings
#
#  id           :integer          not null, primary key
#  account_id   :integer          not null
#  cast_id      :integer          not null
#  character_id :integer          not null
#  person_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
	factory :casting do
		after_build do |casting|
			# association :account
			casting.account = FactoryGirl.create(:account) unless casting.account
			# association :cast
			casting.cast = FactoryGirl.create(:cast, account: casting.account) unless casting.cast
			# association :character
			casting.character = FactoryGirl.create(:character, account: casting.account) unless casting.character
		end
		
		trait :with_person do
			after_build do |casting|
				# association :person
				casting.person = FactoryGirl.create(:person, account: casting.account) unless casting.person
			end
		end
	end
end
