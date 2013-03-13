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
	attr_accessible :title, :start_date, :start_time, :end_time, :location_id

	belongs_to :account
	belongs_to :location
	has_many :invitations, dependent: :destroy
	has_many :employees, through: :invitations

	attr_writer :start_date, :start_time, :end_time
	before_validation :save_start_at, :if => "@start_date.present? && @start_time.present?"
	before_validation :save_end_at, :if => "@start_date.present? && @end_time.present?"
	
	validates :title,	presence: true, length: { maximum: 30 }
	validates :type,	presence: true, length: { maximum: 20 }
	validates :location_id,	presence: true
	validate :location_available, :if => "start_at.present? && end_at.present?"
	validates_date :start_date
	validates_time :start_time
	validates_time :end_time
	validates_datetime :start_at
	validates_datetime :end_at, :after => :start_at, :after_message => "must be after the Start"

	default_scope lambda { order('start_at ASC').where(:account_id => Account.current_id) }
	scope :for_daily_calendar, lambda { |date| where(start_at: date.beginning_of_day..date.end_of_day) }
	scope :for_monthly_calendar, lambda { |date| where(start_at: date.beginning_of_month.beginning_of_week(:sunday)..date.end_of_month.end_of_week(:sunday)) }
		
	def start_date
		@start_date || start_at.try(:strftime, "%D")
	end
	
	def start_time
		@start_time || start_at.try(:to_s, :hr12)
	end
	
	def end_time
		@end_time || end_at.try(:to_s, :hr12)
	end
	
	protected
	
	def location_available
		if id.nil?
			cnt_begin = Event.where(:start_at => start_at..end_at, :location_id => location_id).count
			cnt_end = Event.where(:end_at => start_at..end_at, :location_id => location_id).count
			cnt_subset = Event.where("start_at <= :stime AND end_at >= :etime", { :stime => start_at, :etime => end_at }).where(:location_id => location_id).count
		else
			cnt_begin = Event.where("id <> :id", { :id => id }).where(:start_at => start_at...end_at, :location_id => location_id).count
			cnt_end = Event.where("id <> :id", { :id => id }).where("end_at > :stime AND end_at <= :etime", { :stime => start_at, :etime => end_at }, :location_id => location_id).count
			cnt_subset = Event.where("id <> :id", { :id => id }).where("start_at <= :stime AND end_at >= :etime", { :stime => start_at, :etime => end_at }).where(:location_id => location_id).count
		end
		
		cnt = cnt_begin + cnt_end + cnt_subset
		errors.add(:location_id, "is booked during this time") if cnt > 0
	end
	
	def save_start_at
		stm = (@start_time.kind_of? String) ? @start_time : @start_time.to_s(:db)
		self.start_at = Time.zone.parse(@start_date.to_s(:db) +" "+ stm)
	rescue ArgumentError
		errors.add :start_at, "cannot be parsed"
	end
	
	def save_end_at
		etm = (@end_time.kind_of? String) ? @end_time : @end_time.to_s(:db)
		self.end_at = Time.zone.parse(@start_date.to_s(:db) +" "+ etm)
	rescue ArgumentError
		errors.add :end_at, "cannot be parsed"
	end
end