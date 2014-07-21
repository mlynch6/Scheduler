# == Schema Information
#
# Table name: seasons
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  name       :string(30)       not null
#  start_dt   :date             not null
#  end_dt     :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :season do
		sequence(:name)	{ |n| "Season #{n}" }
	 	start_dt				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
	 	end_dt 					{ start_dt + 6.months }
		
		after_build do |s|
			# association :account
			s.account = FactoryGirl.create(:account) unless s.account
		end
	end
end
