# == Schema Information
#
# Table name: addresses
#
#  id               :integer          not null, primary key
#  addressable_id   :integer          not null
#  addressable_type :string(255)      not null
#  addr_type        :string(30)       not null
#  addr             :string(50)       not null
#  addr2            :string(50)
#  city             :string(50)       not null
#  state            :string(2)        not null
#  zipcode          :string(5)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Address < ActiveRecord::Base
	TYPES = ["Home", "Work"]
	STATES = [[ "Alabama", "AL" ],[ "Alaska", "AK" ],[ "Arizona", "AZ" ],[ "Arkansas", "AR" ],[ "California", "CA" ],
		[ "Colorado", "CO" ],[ "Connecticut", "CT" ],[ "Delaware", "DE" ],[ "District Of Columbia", "DC" ],[ "Florida", "FL" ],
		[ "Georgia", "GA" ],[ "Hawaii", "HI" ],[ "Idaho", "ID" ],[ "Illinois", "IL" ],[ "Indiana", "IN" ],
		[ "Iowa", "IA" ],[ "Kansas", "KS" ],[ "Kentucky", "KY" ],[ "Louisiana", "LA" ],[ "Maine", "ME" ],
		[ "Maryland", "MD" ],[ "Massachusetts", "MA" ],[ "Michigan", "MI" ],[ "Minnesota", "MN" ],[ "Mississippi", "MS" ],
		[ "Missouri", "MO" ],[ "Montana", "MT" ],[ "Nebraska", "NE" ],[ "Nevada", "NV" ],[ "New Hampshire", "NH" ],
		[ "New Jersey", "NJ" ],[ "New Mexico", "NM" ],[ "New York", "NY" ],[ "North Carolina", "NC" ],[ "North Dakota", "ND" ],
		[ "Ohio", "OH" ],[ "Oklahoma", "OK" ],[ "Oregon", "OR" ],[ "Pennsylvania", "PA" ],[ "Rhode Island", "RI" ],
		[ "South Carolina", "SC" ],[ "South Dakota", "SD" ],[ "Tennessee", "TN" ],[ "Texas", "TX" ],[ "Utah", "UT" ],
		[ "Vermont", "VT" ],[ "Virginia", "VA" ],[ "Washington", "WA" ],[ "West Virginia", "WV" ],[ "Wisconsin", "WI" ],
		[ "Wyoming", "WY" ]]
  attr_accessible :addr_type, :addr, :addr2, :city, :state, :zipcode
  
  belongs_to :addressable, :polymorphic => true
  
  #validates :addressable_id,	presence: true
  #validates :addressable_type,	presence: true, length: { maximum: 255 }
  validates :addr_type,	presence: true, length: { maximum: 30 }, :inclusion => { :in => TYPES }
  validates :addr,	presence: true, length: { maximum: 50 }
  validates :addr2,	length: { maximum: 50 }
  validates :city,	presence: true, length: { maximum: 50 }
  validates :state,	presence: true, length: { maximum: 2 }, :inclusion => { :in => STATES.map { |state, abbr| abbr } }
  validates :zipcode,	presence: true, length: { maximum: 5 }
end
