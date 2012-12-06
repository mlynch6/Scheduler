# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  name       :string(100)      not null
#  main_phone :string(13)       not null
#  time_zone  :string(100)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Account < ActiveRecord::Base
  attr_accessible :name, :main_phone, :time_zone, :users_attributes
  
  has_many :users, dependent: :destroy
  accepts_nested_attributes_for :users
  
  validates :name,	presence: true, length: { maximum: 100 }
  VALID_PHONE_REGEX = /\A[0-9]{3}[-. ]?[0-9]{3}[-. ]?[0-9]{4}\z/i
  validates :main_phone,	length: { maximum: 13 }, format: { with: VALID_PHONE_REGEX }
  validates :time_zone,	presence: true, length: { maximum: 100 }, inclusion: { in: ActiveSupport::TimeZone.zones_map(&:name) }
  
  default_scope order: 'accounts.name ASC'
end
