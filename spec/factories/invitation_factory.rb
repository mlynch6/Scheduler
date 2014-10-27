# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  person_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :integer          not null
#  role       :string(20)
#

FactoryGirl.define do
	factory :invitation do
		after_build do |inv|
			# association :account
			inv.account = FactoryGirl.create(:account) unless inv.account
			# association :event
			inv.event = FactoryGirl.create(:event, account: inv.account) unless inv.event
			# association :person
			inv.person = FactoryGirl.create(:person, account: inv.account) unless inv.person
		end
		
		trait :artist do
			role		'Artist'
		end
		
		trait :musician do
			role		'Musician'
		end
	end
end
