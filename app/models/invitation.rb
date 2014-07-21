# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  person_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Invitation < ActiveRecord::Base
  belongs_to :event
	belongs_to :person
	
	validates :event_id,	presence: true
	validates :person_id,	presence: true, uniqueness: { scope: :event_id }
end
