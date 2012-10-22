# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(30)       not null
#  piece_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Role < ActiveRecord::Base
  attr_accessible :name
  
  belongs_to :piece
  #has_and_belongs_to_many :scenes
  
  validates :name, presence: true, length: { maximum: 30 }
  #validates :piece_id, presence: true
  
  default_scope order: 'roles.name ASC'
end
