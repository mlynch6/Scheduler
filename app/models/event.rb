# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  account_id      :integer          not null
#  title           :string(30)       not null
#  type            :string(20)       default("Event"), not null
#  location_id     :integer          not null
#  start_at        :datetime         not null
#  end_at          :datetime         not null
#  piece_id        :integer
#  event_series_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Event < ActiveRecord::Base
	attr_accessible :event_type, :title, :location_id, :start_date, :start_time, :duration, :piece_id
	attr_accessible :employee_ids
	attr_accessor :event_type
	attr_writer :start_date, :start_time, :duration

	belongs_to :account
	belongs_to :location
	belongs_to :event_series
	has_many :invitations, dependent: :destroy
	has_many :employees, through: :invitations

	before_validation :save_start_at, :if => "@start_date.present? && @start_time.present?"
	before_validation :save_end_at, :if => "start_at.present? && @duration.present?"
	
	validates :title,	presence: true, length: { maximum: 30 }
	validates :type,	length: { maximum: 20 }
	validates :location_id,	presence: true
	validate :location_available?, :if => "start_at.present? && end_at.present?"
	validates_date :start_date
	validates :start_date,	presence: true
	validates_time :start_time
	validates :start_time,	presence: true
	validates :duration,	presence: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than => 1440 }

	default_scope lambda { order('start_at ASC').where(:account_id => Account.current_id) }
	scope :for_daily_calendar, lambda { |date| joins(:location).where(start_at: date.beginning_of_day..date.end_of_day).select("events.*, locations.name as location_name").order("locations.name") }
	# Week starts on Monday
	scope :for_week, lambda { |date| where(start_at: date.beginning_of_week.beginning_of_day..date.end_of_week.end_of_day) }
	scope :for_monthly_calendar, lambda { |date| where(start_at: date.beginning_of_month.beginning_of_week(:sunday)..date.end_of_month.end_of_week(:sunday)) }
		
	def start_date
		@start_date || start_at.try(:strftime, "%D")
	end
	
	def start_time
		@start_time || start_at.try(:to_s, :hr12)
	end
	
	def end_time
		end_at.try(:to_s, :hr12)
	end
	
	def duration
		tmp = @duration || ( ((end_at - start_at)/60).to_i if start_at.present? && end_at.present?)
		tmp = tmp.to_i if tmp.kind_of? String
		tmp
	end
	
	def break?
		false
	end
	
	# Used for STI - get correct Model based upon type
	def self.new_with_subclass(type, params = nil)
		klass = (type || 'Event')
		if defined? klass.constantize
			klass.constantize.new(params)
		else
			Event.new(params)
		end
	rescue #invalid type
		Event.new(params)
	end
	
	# Warnings
	def warnings
		w = Hash.new
		
		emp_double_booked_msg = warn_when_employee_double_booked 
		w[:emp_double_booked] = emp_double_booked_msg if emp_double_booked_msg.present?
		
		return w
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
		sdt = (@start_date.kind_of? String) ? Date.strptime(@start_date, '%m/%d/%Y') : @start_date
		stm = (@start_time.kind_of? String) ? @start_time : @start_time.to_s(:db)
		self.start_at = Time.zone.parse(sdt.to_s(:db) +" "+ stm)
	rescue ArgumentError
		errors.add :start_at, "cannot be parsed"
	end
	
	def save_end_at
		dur = (@duration.kind_of? String) ? @duration.to_i : @duration
		self.end_at = self.start_at + dur.minutes
	rescue ArgumentError
		errors.add :end_at, "cannot be parsed"
	end
	
	def contract
		@contract ||= AgmaProfile.find_by_account_id(Account.current_id)
	end
	
	def warn_when_employee_double_booked
		double_booked_employees = Employee.joins(:invitations).where(id: self.employees, invitations: {event_id: self.overlapping}).uniq_by(&:id)
		if double_booked_employees.any?
			employee_list = double_booked_employees.map { |emp| emp.full_name }.join(", ")
			return "The following people are double booked during this time: "+employee_list
		end
	end
	
	# Used by Company Class & Rehearsal
	def check_contracted_start
		stm = (@start_time.kind_of? String) ? @start_time : @start_time.to_s(:hr12)
		if contract.present? && Time.zone.parse(contract.rehearsal_start_time) > Time.zone.parse(stm)
			errors.add(:start_time, "must be on or after the contracted start time of #{contract.rehearsal_start_time}")
		end
	end
	
	def check_contracted_end
		stm = (@start_time.kind_of? String) ? @start_time : @start_time.to_s(:hr12)
		if contract.present? && Time.zone.parse(contract.rehearsal_end_time) < (Time.zone.parse(stm) + duration.minutes)
			errors.add(:duration, "must end on or before the contracted end time of #{contract.rehearsal_end_time}")
		end
	end
	
	def overlapping
		if start_at.present? && end_at.present?
			events = Event.where("(start_at >= :sod AND start_at < :etime) AND (end_at > :stime AND end_at <= :eod)", {
									:stime => start_at,
									:etime => end_at,
									:sod => start_at.beginning_of_day,
									:eod => end_at.end_of_day })
			events.where("id <> :id", { :id => id }) unless new_record?
		end
	end
end
