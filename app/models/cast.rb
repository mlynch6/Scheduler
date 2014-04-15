# == Schema Information
#
# Table name: casts
#
#  id              :integer          not null, primary key
#  season_piece_id :integer          not null
#  name            :string(20)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Cast < ActiveRecord::Base
	belongs_to :season_piece
	has_many :castings, inverse_of: :cast, dependent: :destroy
  
	before_validation :default_name
	after_create :create_blank_casting
	
	validates :season_piece_id, presence: true
	validates :name, presence: true, length: { maximum: 20 }, uniqueness: { scope: :season_piece_id }
  
	default_scope order('name ASC')

private	
	def default_name
		max_name = SeasonPiece.find(season_piece_id).casts.maximum("name") if !season_piece_id.blank?
		self.name = max_name.nil? ? "Cast A" : max_name.next if name.blank?
	end
	
	def create_blank_casting
		characters = self.season_piece.piece.characters
		characters.each do |character|
			casting = self.castings.build
			casting.character = character
			casting.save
		end
	end
end
