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
	attr_accessible :invitee_ids, :period, :end_date
	attr_accessor :event_type, :period, :end_date
	attr_writer :start_date, :start_time, :duration

	belongs_to :account
	belongs_to :location
	belongs_to :event_series
	has_many :invitations, dependent: :destroy
	has_many :invitees, through: :invitations, source: :person

	before_validation :save_start_at, :if => "@start_date.present? && @start_time.present?"
	before_validation :save_end_at, :if => "start_at.present? && @duration.present?"
	
	validates :title,	presence: true, length: { maximum: 30 }
	validates :type,	length: { maximum: 20 }
	validates :location_id,	presence: true
	validates :start_date, presence: true, timeliness: { type: :date }
	validates :start_time, presence: true, timeliness: { type: :time }
	validates :duration,	presence: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than => 1440 }

	default_scope lambda { order('start_at ASC').where(:account_id => Account.current_id) }
	scope :between, lambda { |stime, etime| where(start_at: stime..etime) }
	scope :for_daily_calendar, lambda { |date| between(date.to_time.beginning_of_day, date.to_time.end_of_day).joins(:location) }
	# Week starts on Monday
	scope :for_week, lambda { |date| between(date.beginning_of_week.to_time.beginning_of_day, date.end_of_week.to_time.end_of_day) }
	
		
	def start_date
		sd = @start_date || start_at.try(:to_date).try(:to_s, :default)
		(sd.kind_of? Date) ? sd.to_s(:default) : sd
	end
	
	def start_time
		st = @start_time || start_at.try(:in_time_zone, account.time_zone).try(:to_s, :hr12)
		(st.kind_of? Time) ? st.to_s(:hr12) : st
	end
	
	def end_time
		end_at.try(:in_time_zone, account.time_zone).try(:to_s, :hr12)
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
		
		loc_double_booked_msg = warn_when_location_double_booked 
		w[:loc_double_booked] = loc_double_booked_msg if loc_double_booked_msg.present?
		
		emp_double_booked_msg = warn_when_employee_double_booked 
		w[:emp_double_booked] = emp_double_booked_msg if emp_double_booked_msg.present?
		
		return w
	end
	
protected
	def save_start_at
		sdt = (@start_date.kind_of? String) ? Date.strptime(@start_date, '%m/%d/%Y') : @start_date
		stm = (@start_time.kind_of? String) ? @start_time : @start_time.to_s(:db)
		self.start_at = Time.parse(sdt.to_s(:db) +" "+ stm).in_time_zone(account.time_zone)
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
		@contract ||= AgmaContract.find_by_account_id(Account.current_id)
	end
	
	def warn_when_location_double_booked
		if overlapping_locations.any?
			return "#{location.name} is double booked during this time."
		end
	end
	
	def warn_when_employee_double_booked
		double_booked_people = Person.joins(:invitations).where(id: self.invitees, invitations: {event_id: self.overlapping}).uniq_by(&:id)
		if double_booked_people.any?
			person_list = double_booked_people.map { |person| person.full_name }.join(", ")
			return "The following people are double booked during this time: "+person_list
		end
	end
	
	# Used by Company Class & Rehearsal
	def check_contracted_start
		stm = (@start_time.kind_of? String) ? @start_time : @start_time.to_s(:hr12)
		if contract.present? && Time.zone.parse(contract.rehearsal_start_time) > Time.zone.parse(stm)
			errors.add(:start_time, "must be on or after the contracted start time of #{contract.rehearsal_start_time}")
		end
	end
	
	# Used by Company Class & Rehearsal
	def check_contracted_end
		stm = (@start_time.kind_of? String) ? @start_time : @start_time.to_s(:hr12)
		if contract.present? && Time.zone.parse(contract.rehearsal_end_time) < (Time.zone.parse(stm) + duration.minutes)
			errors.add(:duration, "must end on or before the contracted end time of #{contract.rehearsal_end_time}")
		end
	end
	
	def overlapping
		events = Event.where("(start_at >= :sod AND start_at < :etime) AND (end_at > :stime AND end_at <= :eod)", {
								:stime => start_at,
								:etime => end_at,
								:sod => start_at.beginning_of_day,
								:eod => end_at.end_of_day })
		events.where("id <> :id", { :id => id }) unless new_record?
	end
	
	def overlapping_locations
		events = Event.where("id <> :id", { :id => id }).where(:location_id => location_id)
		events.where("(start_at >= :sod AND start_at < :etime) AND (end_at > :stime AND end_at <= :eod)", {
								:stime => start_at,
								:etime => end_at,
								:sod => start_at.beginning_of_day,
								:eod => end_at.end_of_day })
	end
end
