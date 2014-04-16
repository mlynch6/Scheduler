# == Schema Information
#
# Table name: casts
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
#  season_piece_id :integer          not null
#  name            :string(20)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Cast < ActiveRecord::Base
	belongs_to :account, inverse_of: :casts
	belongs_to :season_piece, inverse_of: :casts
	has_many :castings, inverse_of: :cast, dependent: :destroy
  
	before_validation :default_name
	after_create :create_blank_casting
	
	validates :account_id, presence: true
	validates :season_piece_id, presence: true
	validates :name, presence: true, length: { maximum: 20 }, uniqueness: { scope: :season_piece_id }
  
	default_scope lambda { where(:account_id => Account.current_id).order('name ASC') }

private	
	def default_name
		max_name = self.season_piece.casts.maximum("name") if self.season_piece
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
