# == Schema Information
#
# Table name: lecture_demos
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
	factory :lecture_demo do
		sequence(:title)	{ |n| "Lecture Demo #{n}" }
		
		after_build do |demo|
			# association :account
			demo.account = FactoryGirl.create(:account) unless demo.account
			# association :season
			demo.season = FactoryGirl.create(:season, account: demo.account) unless demo.season
		end
	end
end
