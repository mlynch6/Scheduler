# == Schema Information
#
# Table name: pieces
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  name       :string(50)       not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Piece < ActiveRecord::Base
	attr_accessible :name, :active

	belongs_to :account
	has_many :events, dependent: :destroy
#	has_many :scenes, dependent: :destroy
#	accepts_nested_attributes_for :scenes, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true
#		
#	has_many :roles, dependent: :destroy
#	accepts_nested_attributes_for :roles, :reject_if => lambda { |a| a[:name].blank? }, :allow_destroy => true

	validates :name,	presence: true, length: { maximum: 50 }
	validates :active, :inclusion => { :in => [true, false] }

	default_scope lambda { order('name ASC').where(:account_id => Account.current_id) }
	scope :active, where(:active => true)
	scope :inactive, where(:active => false)
end
