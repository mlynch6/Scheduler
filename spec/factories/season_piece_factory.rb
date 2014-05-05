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
		account
		season
		piece
		
	 	factory :season_piece_published do
			published 			true
		end
	end
	
	factory :season_piece_w_casts do
		after_create { |sp| FactoryGirl.create_list(:cast, 3, season_piece: sp)}
	end
end
