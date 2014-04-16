# == Schema Information
#
# Table name: season_pieces
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  season_id  :integer          not null
#  piece_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SeasonPiece < ActiveRecord::Base
  belongs_to :account, inverse_of: :season_pieces
	belongs_to :season, inverse_of: :season_pieces
	belongs_to :piece, inverse_of: :season_pieces
	has_many :casts, inverse_of: :season_piece, dependent: :destroy
	
	validates :account_id,	presence: true
	validates :season_id,	presence: true
	validates :piece_id,	presence: true, uniqueness: { scope: :season_id }
	
	default_scope lambda { where(:account_id => Account.current_id) }
end
