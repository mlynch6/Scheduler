# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  account_id  :integer          not null
#  title       :string(30)       not null
#  type        :string(20)       not null
#  location_id :integer          not null
#  start_at    :datetime         not null
#  end_at      :datetime         not null
#  piece_id    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Event < ActiveRecord::Base
	attr_accessible :title, :start_at, :end_at, :location

	belongs_to :account
	belongs_to :location

	validates :title,	presence: true, length: { maximum: 30 }
	validates :type,	presence: true, length: { maximum: 20 }
	validates :location_id,	presence: true
	validates_datetime :start_at
	validates_datetime :end_at, :after => :start_at, :after_message => "End Time must be after the Start Time"

	default_scope lambda { order('start_at ASC').where(:account_id => Account.current_id) }
end
