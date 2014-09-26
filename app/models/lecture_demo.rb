# == Schema Information
#
# Table name: lecture_demos
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  season_id  :integer          not null
#  name       :string(50)       not null
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class LectureDemo < ActiveRecord::Base
  attr_accessible :name, :comment
	
	belongs_to :account
	belongs_to :season
	
	validates :account_id,	presence: true
	validates :season_id,	presence: true
	validates :name, presence: true, length: { maximum: 50 }
	
	default_scope lambda { where(:account_id => Account.current_id) }
end
