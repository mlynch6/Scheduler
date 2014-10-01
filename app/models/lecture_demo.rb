# == Schema Information
#
# Table name: lecture_demos
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  season_id  :integer          not null
#  title      :string(30)       not null
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class LectureDemo < ActiveRecord::Base
  attr_accessible :title, :comment, :season_id
	attr_accessible :location_id, :start_date, :start_time, :duration
	
	belongs_to :account
	belongs_to :season
	has_one :event, :as => :schedulable, dependent: :destroy
	has_one :location, :through => :event
	
	delegate :start_date, :start_time, :duration, :time_range, to: :event
	
	validates :account_id,	presence: true
	validates :season_id,	presence: true
	validates :title, presence: true, length: { maximum: 30 }
	
	default_scope lambda { where(:account_id => Account.current_id) }
	
	def self.search(query)
		#Default show all
		lecture_demos = LectureDemo.joins(:event)
		
		if query.include?(:title) && query[:title].present?
			lecture_demos = lecture_demos.where('lecture_demos.title LIKE :q', q: "%#{query[:title]}%")
		end
		
		if query.include?(:season) && query[:season].present?
			lecture_demos = lecture_demos.where(season_id: query[:season])
		end

		if query.include?(:loc) && query[:loc].present?
			lecture_demos = lecture_demos.where(events: { location_id: query[:loc] })
		end
		
		lecture_demos
	end
end
