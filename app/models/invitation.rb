# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  event_id   :integer          not null
#  person_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :integer          not null
#  role       :string(20)
#

class Invitation < ActiveRecord::Base
	ROLES = ["Artist", "Instructor", "Musician"]
	
	attr_accessible :role
	
	belongs_to :account
  belongs_to :event
	belongs_to :person
	
	validates :account_id,	presence: true
	validates :event_id,	presence: true
	validates :person_id,	presence: true, uniqueness: { scope: :event_id }
	validates :role, allow_blank: true, :inclusion => { :in => ROLES }
	
	default_scope lambda { where(:account_id => Account.current_id) }
end
