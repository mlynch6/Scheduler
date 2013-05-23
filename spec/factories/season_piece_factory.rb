# == Schema Information
#
# Table name: season_pieces
#
#  id         :integer          not null, primary key
#  season_id  :integer          not null
#  piece_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
	factory :season_piece do
		season
		piece
	end
	
	factory :season_piece_w_casts do
			after_create { |sp| FactoryGirl.create_list(:cast, 3, season_piece: sp)}
		end
end
