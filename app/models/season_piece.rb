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

class SeasonPiece < ActiveRecord::Base
	attr_accessible :publish
	
  belongs_to :account, inverse_of: :season_pieces
	belongs_to :season, inverse_of: :season_pieces
	belongs_to :piece, inverse_of: :season_pieces
	has_many :casts, inverse_of: :season_piece, dependent: :destroy
	
	before_save :set_published_at, if: "published"
	
	validates :account_id,	presence: true
	validates :season_id,	presence: true
	validates :piece_id,	presence: true, uniqueness: { scope: :season_id }
	validates :published, :inclusion => { :in => [true, false] }
	validates_datetime :published_at, :allow_blank => true
	
	default_scope lambda { where(:account_id => Account.current_id) }
	scope :published_casting, where(:published => true)
	scope :unpublished_casting, where(:published => false)
	
	private
	
	def set_published_at
		self.published_at = Time.zone.now if published_at.blank?
	end
end
