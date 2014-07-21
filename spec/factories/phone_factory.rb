# == Schema Information
#
# Table name: phones
#
#  id             :integer          not null, primary key
#  phoneable_id   :integer          not null
#  phoneable_type :string(255)      not null
#  phone_type     :string(20)       not null
#  phone_num      :string(13)       not null
#  primary        :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
	factory :phone do
		phone_type				"Home"
		phone_num					'111-222-3333'
		
		after_build do |phone|
			#association :phoneable, :factory => :account
			phone.phoneable = FactoryGirl.create(:account) unless phone.phoneable
		end
		
		factory :phone_person, parent: :phone do
			after_build do |phone|
				#association :phoneable, :factory => :person
				phone.phoneable = FactoryGirl.create(:person) unless phone.phoneable
			end
		end
	end
end
