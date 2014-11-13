# == Schema Information
#
# Table name: company_classes
#
#  id          :integer          not null, primary key
#  account_id  :integer          not null
#  season_id   :integer          not null
#  title       :string(30)       not null
#  comment     :text
#  start_at    :datetime         not null
#  duration    :integer          not null
#  end_date    :date             not null
#  location_id :integer          not null
#  monday      :boolean          default(FALSE), not null
#  tuesday     :boolean          default(FALSE), not null
#  wednesday   :boolean          default(FALSE), not null
#  thursday    :boolean          default(FALSE), not null
#  friday      :boolean          default(FALSE), not null
#  saturday    :boolean          default(FALSE), not null
#  sunday      :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CompanyClass < ActiveRecord::Base
  attr_accessible :title, :comment, :season_id, :location_id
	attr_accessible :start_date, :start_time, :duration, :end_date
	attr_accessible :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday
	attr_writer :start_date, :start_time
	
	belongs_to :account
	belongs_to :season
	belongs_to :location
	has_many :events, :as => :schedulable, dependent: :destroy
	
	before_validation :save_start_at, :if => "start_date.present? && start_time.present?"
	after_create :generate_events
	
	validates :account_id,	presence: true
	validates :season_id,	presence: true
	validates :title,	presence: true, length: { maximum: 30 }
	validates :start_date, presence: true, timeliness: { type: :date }
	validates :start_time, presence: true, timeliness: { type: :time }
	validates :duration,	presence: true, :numericality => { :only_integer => true, :greater_than => 0, :less_than => 1440 }
	validates_date :end_date, :on_or_after => :start_date, :on_or_after_message => "must be on or after the Start Date"
	validates :end_date, presence: true
	validates :location_id,	presence: true
	validates :monday, :inclusion => { :in => [true, false] }
	validates :tuesday, :inclusion => { :in => [true, false] }
	validates :wednesday, :inclusion => { :in => [true, false] }
	validates :thursday, :inclusion => { :in => [true, false] }
	validates :friday, :inclusion => { :in => [true, false] }
	validates :saturday, :inclusion => { :in => [true, false] }
	validates :sunday, :inclusion => { :in => [true, false] }
	validate :day_of_week_selected
# 	validate :check_contracted_start, :if => "start_time.present?"
# 	validate :check_contracted_end, :if => "start_time.present? && duration.present?"
# 	validate :check_duration_increments, :if => "start_at.present? && end_at.present?"

	default_scope lambda { order('company_classes.start_at ASC').where(:account_id => Account.current_id) }
	
	def start_date
		@start_date || start_at.try(:in_time_zone, timezone).try(:to_date).try(:to_s, :default)
	end
	
	def start_time
		@start_time || start_at.try(:in_time_zone, timezone).try(:to_s, :hr12)
	end
	
	def end_time
		(start_at + duration*60).in_time_zone(timezone).to_s(:hr12)
	end

	def date_range
		"#{start_date} to #{end_date.to_s(:default)}"
	end
	
	def time_range
		"#{start_time} to #{end_time}"
	end
	
	def days_of_week
		dow = ""
		dow += 'Su ' if sunday?
		dow += 'M ' if monday?
		dow += 'T ' if tuesday?
		dow += 'W ' if wednesday?
		dow += 'Th ' if thursday?
		dow += 'F ' if friday?
		dow += 'Sa ' if saturday?
		
		dow.strip
	end

	def self.search(query)
		#Default show all
		company_classes = CompanyClass.joins(:location)
		
		if query.include?(:title) && query[:title].present?
			company_classes = company_classes.where('company_classes.title LIKE :q', q: "%#{query[:title]}%")
		end
		
		if query.include?(:season) && query[:season].present?
			company_classes = company_classes.where(season_id: query[:season])
		end

		if query.include?(:loc) && query[:loc].present?
			company_classes = company_classes.where(location_id: query[:loc])
		end
		
		company_classes
	end
	
private
	def save_start_at
		date_time_text = Date.strptime(start_date, '%m/%d/%Y').to_s(:db) + " " + start_time
		self.start_at = ActiveSupport::TimeZone[timezone].parse(date_time_text)
	rescue ArgumentError
		errors.add :start_at, "cannot be parsed"
	end
	
	def day_of_week_selected
		errors.add(:base, "At least 1 Day of Week should be selected") unless (monday? || tuesday? || wednesday? || thursday? || friday? || saturday? || sunday?)
	end
	
	def generate_events
		dates = []
		myRange = (Date.strptime(start_date, '%m/%d/%Y')..end_date).to_a
		
		dates = myRange.keep_if { |dt| (dt.monday? && self.monday?) || 
																	(dt.tuesday? && self.tuesday?) || 
																	(dt.wednesday? && self.wednesday?) || 
																	(dt.thursday? && self.thursday?) || 
																	(dt.friday? && self.friday?) || 
																	(dt.saturday? && self.saturday?) || 
																	(dt.sunday? && self.sunday?)
															}
			
		dates.each do |dt|
			e = events.build(
					title: title, 
					location_id: location_id, 
					start_date: dt.to_s,
					start_time: start_time,
					duration: duration)
			e.account = account if Account.current_id.nil?
			e.save!
		end
	end
	
	def timezone
		@timezone ||= Account.find(Account.current_id).time_zone if Account.current_id
		@timezone ||= account.time_zone if account
	end
	
	

# 	def check_duration_increments
# 		if contract.present? && duration.remainder(contract.rehearsal_increment_min) != 0
# 			errors.add(:duration, "must be in increments of #{contract.rehearsal_increment_min} minutes")
# 		end
# 	end
end
