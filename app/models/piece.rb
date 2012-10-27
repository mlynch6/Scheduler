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
	attr_accessible :active, :name, :scenes_attributes, :roles_attributes
	
	has_many :scenes, dependent: :destroy
	accepts_nested_attributes_for :scenes, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true
		
	has_many :roles, dependent: :destroy
	accepts_nested_attributes_for :roles, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true
		
	has_many :events, dependent: :destroy
	
	validates :name,	presence: true, length: { maximum: 50 }
	validates :active, :inclusion => { :in => [true, false] }
	
	default_scope order: 'pieces.name ASC'
	scope :active, where(:active => true)
	scope :inactive, where(:active => false)
end
