# == Schema Information
#
# Table name: pieces
#
#  id            :integer          not null, primary key
#  account_id    :integer          not null
#  name          :string(50)       not null
#  choreographer :string(50)
#  music         :string(50)
#  composer      :string(50)
#  avg_length    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Piece < ActiveRecord::Base
	attr_accessible :name, :choreographer, :music, :composer, :avg_length

	belongs_to :account
	has_many :events, dependent: :destroy
	has_many :scenes, dependent: :destroy
	has_many :characters, dependent: :destroy
	has_many :season_pieces, dependent: :destroy
	has_many :seasons, through: :season_pieces

	validates :name,	presence: true, length: { maximum: 50 },
			uniqueness: { scope: [:account_id, :choreographer], message: "/Choreographer combination has already been taken" }
	validates :choreographer,	length: { maximum: 50 }
	validates :music,	length: { maximum: 50 }
	validates :composer, length: { maximum: 50 }
	validates :avg_length, allow_blank: true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0, :less_than => 1440 }

	default_scope lambda { order('name ASC').where(:account_id => Account.current_id) }
	
	def name_w_choreographer
		choreographer.present? ? "#{name} (#{choreographer})" : name
	end
end
