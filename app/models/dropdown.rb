# == Schema Information
#
# Table name: dropdowns
#
#  id            :integer          not null, primary key
#  dropdown_type :string(30)       not null
#  name          :string(30)       not null
#  comment       :text
#  position      :integer          not null
#  active        :boolean          default(TRUE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Dropdown < ActiveRecord::Base
	TYPES = ['PhoneType', 'UserRole']
  attr_accessible :name, :comment, :position, :active
	
	has_many :permissions, foreign_key: 'role_id', dependent: :destroy
	
	validates :dropdown_type, presence: true, length: { maximum: 30 }, :inclusion => { :in => TYPES }
	validates :name, presence: true, length: { maximum: 30 }, uniqueness: { scope: :dropdown_type }
	validates :position, :numericality => {:only_integer => true, :greater_than => 0 }, allow_blank: true
	validates :active, :inclusion => { :in => [true, false] }
	
	before_save :set_position, :if => "position.blank?"
	
	default_scope lambda { order('position ASC') }
	scope :of_type, lambda { |value| where(:dropdown_type => value) }
	scope :active, where(:active => true)
	scope :inactive, where(:active => false)
	
	def status
		self.active? ? "Active" : "Inactive"
	end
	
	def self.search(query)
		#Default show all
		dropdowns = Dropdown.order('position ASC')
		
		if query.include?(:type)
			dropdowns = dropdowns.of_type(query[:type])
		end
		
		if query.include?(:query)
			dropdowns = dropdowns.where('name LIKE :q', q: "%#{query[:query]}%")
		end
		
		if query.include?(:status) && query[:status] == "active"
			dropdowns = dropdowns.active
		elsif query.include?(:status) && query[:status] == "inactive"
			dropdowns = dropdowns.inactive
		end
		
		dropdowns
	end
	
private

	def set_position
		curr_max_position = Dropdown.where(dropdown_type: self.dropdown_type).maximum('position')
		curr_max_position = 0 if curr_max_position.nil?
		self.position = curr_max_position + 1
	end
end
