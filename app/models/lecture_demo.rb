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
	include ActionView::Helpers::TextHelper
	
  attr_accessible :title, :comment, :season_id
	
	belongs_to :account, inverse_of: :lecture_demos
	belongs_to :season, inverse_of: :lecture_demos
	has_one :event, :as => :schedulable, dependent: :destroy
	has_one :location, :through => :event
	has_many :invitations, :through => :event
	has_many :invitees, through: :invitations, source: :person
	
	delegate :start_date, :start_time, :duration, :time_range, to: :event
	
	validates :account,	presence: true
	validates :season,	presence: true
	validates :title, presence: true, length: { maximum: 30 }
	validate :duration_less_than_contract_duration
	validate :max_demos_per_day
	
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
	
	def event
		super || build_event(title: title)
	end

private
	def duration_less_than_contract_duration
		if duration.present? && contract && contract.demo_max_duration.present? 
			max_duration = contract.demo_max_duration
			if duration > max_duration
				errors.add(:duration, "can't be more than #{pluralize(max_duration, 'minute')}")
			end
		end
	end
	
	def max_demos_per_day
		if start_date.present? && contract && contract.demo_max_num_per_day.present?
			max_num = contract.demo_max_num_per_day
			
			if new_record?
				existing_count = Event.where(schedulable_type: 'LectureDemo').for_day(Date.strptime(start_date, '%m/%d/%Y')).count
			else
				existing_count = Event.where(schedulable_type: 'LectureDemo').where('id <> :id', id: event.id).for_day(Date.strptime(start_date, '%m/%d/%Y')).count
			end
			
			if existing_count >= max_num
				errors.add(:base, "No more than #{pluralize(max_num, 'Lecture Demo')} can be scheduled in a day")
			end
		end
	end
	
	def contract
		@contract ||= AgmaContract.first
	end
end
