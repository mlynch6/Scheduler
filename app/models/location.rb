# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  name       :string(50)       not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Location < ActiveRecord::Base
  attr_accessible :name, :active
	
	belongs_to :account
	has_many :events, dependent: :destroy
	has_many :company_classes, dependent: :destroy
		
	validates :name, presence: true, length: { maximum: 50 }, uniqueness: { scope: :account_id }
	validates :active, :inclusion => { :in => [true, false] }
	
	default_scope lambda { order('name ASC').where(:account_id => Account.current_id) }
	scope :active, where(:active => true)
	scope :inactive, where(:active => false)
	
	def activate
		self.update_attribute(:active, true)
	end
	
	def inactivate
		self.update_attribute(:active, false)
	end
	
	def status
		self.active? ? "Active" : "Inactive"
	end
	
	def self.search(query)
		#Default show all
		locations = Location.order('name ASC')
		
		if query.include?(:query)
			locations = locations.where('name LIKE :q', q: "%#{query[:query]}%")
		end
		
		if query.include?(:status) && query[:status] == "active"
			locations = locations.active
		elsif query.include?(:status) && query[:status] == "inactive"
			locations = locations.inactive
		end
		
		locations
	end
end
