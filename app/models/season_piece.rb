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

class SeasonPiece < ActiveRecord::Base
  belongs_to :season
	belongs_to :piece
	
	validates :season_id,	presence: true
	validates :piece_id,	presence: true, uniqueness: { scope: :season_id }
end
