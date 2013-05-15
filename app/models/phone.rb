# == Schema Information
#
# Table name: phones
#
#  id             :integer          not null, primary key
#  phoneable_id   :integer          not null
#  phoneable_type :string(255)      not null
#  phone_type     :string(20)       not null
#  phone_num      :string(13)       not null
#  primary        :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Phone < ActiveRecord::Base
	TYPES = ["Home", "Work", "Cell", "Fax", "Emergency"]
  attr_accessible :phone_type, :phone_num, :primary
  
  belongs_to :phoneable, :polymorphic => true
  
  #validates :phoneable_id,	presence: true
  #validates :phoneable_type,	presence: true, length: { maximum: 255 }
  validates :phone_type,	presence: true, length: { maximum: 20 }, :inclusion => { :in => TYPES }
  validates :phone_num,	presence: true, phone: true, length: { maximum: 13 }
  validates :primary, :inclusion => { :in => [true, false] }
end
