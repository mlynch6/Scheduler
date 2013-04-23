# == Schema Information
#
# Table name: appearances
#
#  id           :integer          not null, primary key
#  scene_id     :integer          not null
#  character_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Appearance < ActiveRecord::Base
  belongs_to :scene
  belongs_to :character
  
  validates :scene_id,	presence: true
	validates :character_id,	presence: true
end
