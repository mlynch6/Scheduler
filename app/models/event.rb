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
	attr_accessible :employee_ids
	attr_writer :start_date, :start_time, :end_time

	belongs_to :account
	belongs_to :location
	has_many :invitations, dependent: :destroy
	has_many :employees, through: :invitations

	before_validation :save_start_at, :if => "@start_date.present? && @start_time.present?"
	before_validation :save_end_at, :if => "@start_date.present? && @end_time.present?"
	
	validates :title,	presence: true, length: { maximum: 30 }
	validates :type,	presence: true, length: { maximum: 20 }
	validates :location_id,	presence: true
	validate :location_available?, :if => "start_at.present? && end_at.present?"
	validates_date :start_date
	validates :start_date,	presence: true
	validates_time :start_time
	validates :start_time,	presence: true
	validates_time :end_time, :after => :start_time, :after_message => "must be after the Start Time"
	validates :end_time,	presence: true

	default_scope lambda { order('start_at ASC').where(:account_id => Account.current_id) }
	scope :for_daily_calendar, lambda { |date| joins(:location).where(start_at: date.beginning_of_day..date.end_of_day).select("events.*, locations.name as location_name").order("locations.name") }
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
	
	def duration_min
		((end_at - start_at)/60).to_i
	end
	
	def overlapping
		events = Event.where("(start_at >= :sod AND start_at < :etime) AND (end_at > :stime AND end_at <= :eod)", {
									:stime => start_at,
									:etime => end_at,
									:sod => start_at.beginning_of_day,
									:eod => end_at.end_of_day })
		events.where("id <> :id", { :id => id }) if !new_record?
	end
	
	def double_booked_employees_warning
		double_booked_employees = Employee.joins(:invitations).where(id: self.employees, invitations: {event_id: self.overlapping}).uniq_by(&:id)
		if double_booked_employees.any?
			employee_list = double_booked_employees.map { |emp| emp.full_name }.join(", ")
			return "The following people are double booked during this time: "+employee_list
		end
	end
	
protected
	
	def location_available?
		if new_record?
			events = Event.where("(start_at >= :sod AND start_at < :etime) AND (end_at > :stime AND end_at <= :eod) AND location_id = :location_id", {
									:stime => start_at,
									:etime => end_at,
									:sod => start_at.beginning_of_day,
									:eod => end_at.end_of_day,
									:location_id => location_id})
		else
			events = Event.where("(start_at >= :sod AND start_at < :etime) AND (end_at > :stime AND end_at <= :eod) AND location_id = :location_id AND id <> :id", {
									:stime => start_at,
									:etime => end_at,
									:sod => start_at.beginning_of_day,
									:eod => end_at.end_of_day,
									:location_id => location_id,
									:id => id })
		end
		errors.add(:location_id, "is booked during this time") if events.count > 0
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