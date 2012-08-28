# == Schema Information
#
# Table name: pieces
#
#  id         :integer          not null, primary key
#  name       :string(50)       not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Piece < ActiveRecord::Base
	attr_accessible :active, :name
	
	validates :name,	presence: true, length: { maximum: 50 }
	validates :active, presence: true
end
