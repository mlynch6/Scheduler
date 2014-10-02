# == Schema Information
#
# Table name: company_classes
#
#  id          :integer          not null, primary key
#  account_id  :integer          not null
#  season_id   :integer
#  title       :string(30)       not null
#  comment     :text
#  start_at    :datetime         not null
#  duration    :integer          not null
#  end_date    :date             not null
#  location_id :integer          not null
#  monday      :boolean          default(FALSE), not null
#  tuesday     :boolean          default(FALSE), not null
#  wednesday   :boolean          default(FALSE), not null
#  thursday    :boolean          default(FALSE), not null
#  friday      :boolean          default(FALSE), not null
#  saturday    :boolean          default(FALSE), not null
#  sunday      :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
	factory :company_class do
		sequence(:title)	{ |n| "Company Class #{n}" }
		start_date	{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		start_time	"9:15AM"
		duration		60
		end_date		{ start_date + 2.months }
		monday			false
		tuesday			true
		wednesday		false
		thursday		true
		friday			false
		saturday		false
		sunday			false
		
		after_build do |company_class|
			# association :account
			company_class.account = FactoryGirl.create(:account) unless company_class.account
			# association :season
			company_class.season = FactoryGirl.create(:season, account: company_class.account) unless company_class.season
			# association :location
			company_class.location = FactoryGirl.create(:location, account: company_class.account) unless company_class.location
		end
	end
end
