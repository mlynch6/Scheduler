# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string(50)       not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Location < ActiveRecord::Base
  attr_accessible :active, :name
	
	has_many :events, dependent: :destroy
		
	validates :name,	presence: true, length: { maximum: 50 }
	validates :active, :inclusion => { :in => [true, false] }
	
	default_scope order: 'locations.name ASC'
	scope :active, where(:active => true)
	scope :inactive, where(:active => false)
end