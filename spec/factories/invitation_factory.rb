# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  person_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :invitation do
		after_build do |inv|
			# association :event
			inv.event = FactoryGirl.create(:event) unless inv.event
			# association :person
			inv.person = FactoryGirl.create(:person, account: inv.event.account) unless inv.person
		end
	end
end
