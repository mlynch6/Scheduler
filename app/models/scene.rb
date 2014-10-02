# == Schema Information
#
# Table name: scenes
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  piece_id   :integer          not null
#  name       :string(100)      not null
#  position   :integer          not null
#  track      :string(20)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Scene < ActiveRecord::Base
  attr_accessible :name, :track
  attr_accessible :character_ids
  
  belongs_to :account
  belongs_to :piece
  has_many :appearances, dependent: :destroy
  has_many :characters, through: :appearances
	has_many :rehearsals, dependent: :destroy
  
  validates :account_id, presence: true
  validates :piece_id, presence: true
  validates :name, presence: true, length: { maximum: 100 }
  validates :position, :numericality => {:only_integer => true, :greater_than => 0 }, allow_blank: true
  validates :track, length: { maximum: 20 }
  
  before_save :set_position, :if => "position.blank?"
  
	default_scope lambda { where(:account_id => Account.current_id).order('scenes.position ASC') }

private

	def set_position
		curr_max_position = self.piece.scenes.maximum('position')
		curr_max_position = 0 if curr_max_position.nil?
		self.position = curr_max_position + 1
	end
end
