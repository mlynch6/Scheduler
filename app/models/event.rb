# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  title       :string(30)       not null
#  event_type  :string(20)       not null
#  location_id :integer          not null
#  start_at    :datetime         not null
#  end_at      :datetime         not null
#  piece_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Event < ActiveRecord::Base
  attr_accessible :title, :event_type, :start_at, :end_at
  
  belongs_to :location
  belongs_to :piece
  
  validates :title,	presence: true, length: { maximum: 30 }
  validates :event_type,	presence: true, length: { maximum: 20 }
  validates :location_id,	presence: true
  validates_datetime :start_at
	validates_datetime :end_at, :after => :start_at, :after_message => "End Time must be after the Start Time"
  
  default_scope order: 'events.start_at ASC'
end
