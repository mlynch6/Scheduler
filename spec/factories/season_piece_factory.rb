# == Schema Information
#
# Table name: season_pieces
#
#  id           :integer          not null, primary key
#  account_id   :integer          not null
#  season_id    :integer          not null
#  piece_id     :integer          not null
#  published    :boolean          default(FALSE), not null
#  published_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
	factory :season_piece do
		after_build do |sp|
			# association :account
			sp.account = FactoryGirl.create(:account) unless sp.account
			
			# association :season
			sp.season = FactoryGirl.create(:season, account: sp.account) unless sp.season
			
			# association :piece
			sp.piece = FactoryGirl.create(:piece, account: sp.account) unless sp.piece
		end
		
	 	trait :published do
			published 			true
		end
		
		trait :with_casts do
			after_create { |sp| FactoryGirl.create_list(:cast, 3, season_piece: sp)}
		end
	end
end
