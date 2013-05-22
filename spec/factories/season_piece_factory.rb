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
end
