# == Schema Information
#
# Table name: events
#
#  id               :integer          not null, primary key
#  account_id       :integer          not null
#  schedulable_id   :integer          not null
#  schedulable_type :string(255)      not null
#  title            :string(30)       not null
#  location_id      :integer
#  start_at         :datetime         not null
#  end_at           :datetime         not null
#  comment          :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Event < ActiveRecord::Base
	attr_accessible :title, :location_id, :start_date, :start_time, :duration, :comment
	attr_accessible :invitee_ids, :musician_ids, :artist_ids, :instructor_ids
	attr_writer :start_date, :start_time, :duration

	belongs_to :account
	belongs_to :location
	belongs_to :schedulable, :polymorphic => true
	has_many :invitations, dependent: :destroy
	has_many :invitees, through: :invitations, source: :person
	
	has_many :artist_invitations, dependent: :destroy,
			class_name: 'Invitation', conditions: { role: 'Artist' }
	has_many :artists, through: :artist_invitations, source: :person
	
	has_many :instructor_invitations, dependent: :destroy,
			class_name: 'Invitation', conditions: { role: 'Instructor' }
	has_many :instructors, through: :instructor_invitations, source: :person
	
	has_many :musician_invitations, dependent: :destroy,
			class_name: 'Invitation', conditions: { role: 'Musician' }
	has_many :musicians, through: :musician_invitations, source: :person

	before_validation :save_start_at, :if => "@start_date.present? && @start_time.present?"
	before_validation :save_end_at, :if => "start_at.present? && @duration.present?"
	
	validates :title,	presence: true, length: { maximum: 30 }
	validates :start_date, presence: true, timeliness: { type: :date }
	validates :start_time, presence: true, timeliness: { type: :time }
	validates :duration,	presence: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than => 1440 }

	default_scope lambda { order('start_at ASC').where(:account_id => Account.current_id) }
	scope :between, lambda { |stime, etime| where(start_at: stime..etime) }
	scope :for_day, ( lambda do |date|
			timezone = Account.find(Account.current_id).time_zone
			date_in_time_zone = ActiveSupport::TimeZone[timezone].parse(date.to_s(:db))
			between(date_in_time_zone.beginning_of_day, date_in_time_zone.end_of_day)
		end )
	# Week starts on Monday
	scope :for_week, ( lambda do |date|
			timezone = Account.find(Account.current_id).time_zone
			date_in_time_zone = ActiveSupport::TimeZone[timezone].parse(date.to_s(:db))
			between(date_in_time_zone.beginning_of_week, date_in_time_zone.end_of_week)
		end )
		
	def start_date(format = :default)
		sd = @start_date || start_at.try(:in_time_zone, timezone).try(:to_date).try(:to_s, format)
		#Return a string
		(sd.kind_of? Date) ? sd.to_s(format) : sd
	end
	
	def start_time(format = :hr12)
		st = @start_time || start_at.try(:in_time_zone, timezone).try(:to_s, format)
		#Return a string
		(st.kind_of? Time) ? st.to_s(format) : st
	end
	
	def end_time(format = :hr12)
		et = (ActiveSupport::TimeZone[timezone].parse(start_time) + duration.minutes) if start_time.present? && duration.present?
		et ||= end_at
		et.try(:to_s, format)
	end
	
	def duration
		tmp = @duration || ( ((end_at - start_at)/60).to_i if start_at.present? && end_at.present?)
		tmp = tmp.to_i if tmp.kind_of? String
		tmp
	end
	
	def time_range(format = :hr12)
		"#{start_time(format)} to #{end_time(format)}"
	end
	
	def event_type
		schedulable_type.underscore.titleize
	end
	
	def overlaps?(event2)
		(start_at - event2.end_at) * (event2.start_at - end_at) > 0
	end
	
	def self.search(query)
		#Default show all
		events = Event.order('start_at ASC')
		
		if query.include?(:date)
			if query.include?(:range) && query[:range] == "week"
				events = events.for_week(query[:date])
			else
				events = events.for_day(query[:date])
			end
		end
		
		events
	end
	
protected
	def save_start_at
		date_time_text = Date.strptime(start_date, '%m/%d/%Y').to_s(:db) + " " + start_time
		self.start_at = ActiveSupport::TimeZone[timezone].parse(date_time_text)
	rescue ArgumentError
		errors.add :start_at, "cannot be parsed"
	end
	
	def save_end_at
		dur = (@duration.kind_of? String) ? @duration.to_i : @duration
		self.end_at = self.start_at + dur.minutes
	rescue ArgumentError
		errors.add :end_at, "cannot be parsed"
	end
	
	def timezone
		@timezone ||= Account.find(Account.current_id).time_zone if Account.current_id
		@timezone ||= account.time_zone if account
	end
end
