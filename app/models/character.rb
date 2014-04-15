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
#

class Character < ActiveRecord::Base
  attr_accessible :name
  
  belongs_to :account
  belongs_to :piece
  has_many :appearances, dependent: :destroy
	has_many :castings, inverse_of: :character, dependent: :destroy
  
  validates :account_id, presence: true
  validates :piece_id, presence: true
  validates :name, presence: true, length: { maximum: 30 }
  validates :position, :numericality => {:only_integer => true, :greater_than => 0 }, allow_blank: true
  
  before_save :set_position, :if => "position.blank?"
  
	default_scope lambda { where(:account_id => Account.current_id).order('position ASC') }

private

	def set_position
		curr_max_position = self.piece.characters.maximum('position')
		curr_max_position = 0 if curr_max_position.nil?
		self.position = curr_max_position + 1
	end
end
