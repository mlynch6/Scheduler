# == Schema Information
#
# Table name: costume_fittings
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  season_id  :integer          not null
#  title      :string(30)       not null
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :costume_fitting do
		sequence(:title)	{ |n| "Costume Fitting #{n}" }
		
		after_build do |fitting|
			# association :account
			fitting.account = FactoryGirl.create(:account) unless fitting.account
			# association :season
			fitting.season = FactoryGirl.create(:season, account: fitting.account) unless fitting.season
		end
	end
end
