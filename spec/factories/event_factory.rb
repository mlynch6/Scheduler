# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
#  title           :string(30)       not null
#  type            :string(20)       default("Event"), not null
#  location_id     :integer          not null
#  start_at        :datetime         not null
#  end_at          :datetime         not null
#  piece_id        :integer
#  event_series_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

FactoryGirl.define do
	factory :event do
		sequence(:title)	{ |n| "Event #{n}" }
		start_date				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		start_time				"9:15AM"
		duration					60
		
		after_build do |e|
			# association :account
			e.account = FactoryGirl.create(:account) unless e.account
			# association :location
			e.location = FactoryGirl.create(:location, account: e.account) unless e.location
		end
	end
	
	factory :company_class do
		sequence(:title)	{ |n| "Company Class #{n}" }
		start_date				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		start_time				"9:15AM"
		duration					60
		
		after_build do |e|
			# association :account
			e.account = FactoryGirl.create(:account) unless e.account
			# association :location
			e.location = FactoryGirl.create(:location, account: e.account) unless e.location
		end
	end
	
	factory :rehearsal do
		sequence(:title)	{ |n| "Rehearsal #{n}" }
		start_date				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		start_time				"9:15AM"
		duration					60
		
		after_build do |e|
			# association :account
			e.account = FactoryGirl.create(:account) unless e.account
			# association :location
			e.location = FactoryGirl.create(:location, account: e.account) unless e.location
			# association :piece
			e.piece = FactoryGirl.create(:piece, account: e.account) unless e.piece
		end
	end
	
	factory :costume_fitting do
		sequence(:title)	{ |n| "Costume Fitting #{n}" }
		start_date				{ Date.new(Random.rand(2000..2013), Random.rand(12)+1, Random.rand(28)+1) }
		start_time				"8:45AM"
		duration					30
		
		after_build do |e|
			# association :account
			e.account = FactoryGirl.create(:account) unless e.account
			# association :location
			e.location = FactoryGirl.create(:location, account: e.account) unless e.location
		end
	end
end
