# == Schema Information
#
# Table name: characters
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  piece_id   :integer          not null
#  name       :string(30)       not null
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  gender     :string(10)
#  animal     :boolean          default(FALSE), not null
#  is_child   :boolean          default(FALSE), not null
#  speaking   :boolean          default(FALSE), not null
#  deleted    :boolean          default(FALSE), not null
#  deleted_at :datetime
#

class Character < ActiveRecord::Base
  attr_accessible :name, :gender, :is_child, :animal, :speaking
  
  belongs_to :account
  belongs_to :piece
  has_many :appearances, dependent: :destroy
	has_many :castings, inverse_of: :character, dependent: :destroy
  
  validates :account_id, presence: true
  validates :piece_id, presence: true
  validates :name, presence: true, length: { maximum: 30 }
  validates :position, :numericality => {:only_integer => true, :greater_than => 0 }, allow_blank: true
	validates :gender, :inclusion => { :in => ['Male', 'Female'] }, allow_blank: true
	validates :animal, :inclusion => { :in => [true, false] }
	validates :is_child, :inclusion => { :in => [true, false] }
	validates :speaking, :inclusion => { :in => [true, false] }
	validates :deleted, :inclusion => { :in => [true, false] }
	validates_datetime :deleted_at, :allow_blank => true
  
  before_save :set_position, :if => "position.blank?"
	before_save :set_deleted_at, if: "deleted"
	after_create :create_casting_records
  
	default_scope lambda { where(:account_id => Account.current_id).order('position ASC') }
	scope :active, where(:deleted => false)

	def soft_delete
		has_published = Casting.joins(cast: :season_piece).merge(SeasonPiece.unscoped.published_casting).where(character_id: id).exists?
		if has_published
			self.update_attribute(:deleted, true)
			unpublished_castings = Casting.joins(cast: :season_piece).merge(SeasonPiece.unscoped.unpublished_casting).where(character_id: id)
			unpublished_castings.each do |casting|
				casting.destroy
			end
		else
			self.destroy
		end
	end

private

	def set_position
		curr_max_position = self.piece.characters.maximum('position')
		curr_max_position = 0 if curr_max_position.nil?
		self.position = curr_max_position + 1
	end
	
	def create_casting_records
		unpublished_casts = Cast.joins(:season_piece).merge(SeasonPiece.unscoped.unpublished_casting).where(season_pieces: {piece_id: piece_id})
		unpublished_casts.each do |cast|
			cast.castings.create(character_id: id)
		end
	end
	
	def set_deleted_at
		self.deleted_at = Time.zone.now if deleted_at.blank?
	end
end
