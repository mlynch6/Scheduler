# == Schema Information
#
# Table name: scenes
#
#  id         :integer          not null, primary key
#  name       :string(100)      not null
#  order_num  :integer          not null
#  piece_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Scene < ActiveRecord::Base
  attr_accessible :name, :order_num
  
  belongs_to :piece
  #has_and_belongs_to_many :roles
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :order_num, presence: true, :numericality => {:only_integer => true, :greater_than => 0 }
  #validates :piece_id, presence: true
  
  before_save :update_scene_order
  
  default_scope order: 'scenes.order_num ASC'
  
  
  def update_scene_order
  	scenes = Scene.where(:piece_id => self.piece_id, :order_num => self.order_num)
  	scenes.each do |s|
	  	s.update_attribute(:order_num, self.order_num + 1) unless s.id == self.id
	  end
	end
end
