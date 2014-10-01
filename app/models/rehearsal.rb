# == Schema Information
#
# Table name: rehearsals
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  season_id  :integer          not null
#  title      :string(30)       not null
#  piece_id   :integer          not null
#  scene_id   :integer
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Rehearsal < ActiveRecord::Base
  attr_accessible :title, :comment, :season_id, :piece_id, :scene_id
	attr_accessible :location_id, :start_date, :start_time, :duration
	
	belongs_to :account
	belongs_to :season
	belongs_to :piece
	belongs_to :scene
	has_one :event, :as => :schedulable, dependent: :destroy
	has_one :location, :through => :event
	
	delegate :start_date, :start_time, :duration, :time_range, to: :event
	
	validates :account_id,	presence: true
	validates :season_id,	presence: true
	validates :title, presence: true, length: { maximum: 30 }
	validates :piece_id,	presence: true
	
	default_scope lambda { where(:account_id => Account.current_id) }
	
	def self.search(query)
		#Default show all
		rehearsals = Rehearsal.joins(:event)
		
		if query.include?(:title) && query[:title].present?
			rehearsals = rehearsals.where('rehearsals.title LIKE :q', q: "%#{query[:title]}%")
		end
		
		if query.include?(:season) && query[:season].present?
			rehearsals = rehearsals.where(season_id: query[:season])
		end

		if query.include?(:loc) && query[:loc].present?
			rehearsals = rehearsals.where(events: { location_id: query[:loc] })
		end
		
		if query.include?(:piece) && query[:piece].present?
			rehearsals = rehearsals.where(piece_id: query[:piece])
		end
		
		rehearsals
	end
	
	# validate :check_contracted_start, :if => "start_time.present?"
# 	validate :check_contracted_end, :if => "start_time.present? && duration.present?"
# 	validate :check_duration_increments, :if => "start_at.present? && end_at.present?"
# 	validate :check_company_class_break, :if => "start_date.present? && start_time.present?"
#
# 	def break_duration
# 		break_record = get_break_record
# 		break_record.present? ? break_record.break_min : 0
# 	end
#
# 	def break_time
# 		break_record = get_break_record
#
# 		if break_record.present?
# 			break_start = end_at - break_record.break_min*60
# 			return "#{break_start.in_time_zone(account.time_zone).to_s(:hr12)} to #{end_time}"
# 		else
# 			return nil
# 		end
# 	end
#
# 	# Warnings
# 	def warnings
# 		w = super
#
# 		emp_max_hr_per_day_msg = warn_when_emp_over_hrs_per_day
# 		w[:emp_max_hr_per_day] = emp_max_hr_per_day_msg if emp_max_hr_per_day_msg.present?
#
# 		emp_max_hr_per_week_msg = warn_when_emp_over_hrs_per_week
# 		w[:emp_max_hr_per_week] = emp_max_hr_per_week_msg if emp_max_hr_per_week_msg.present?
#
# 		return w
# 	end
#
# protected
#
# 	def check_duration_increments
# 		if contract.present? && duration.remainder(contract.rehearsal_increment_min) != 0
# 			errors.add(:duration, "must be in increments of #{contract.rehearsal_increment_min} minutes")
# 		end
# 	end
#
# 	#Rehearsal cannot start during the break following the company class
# 	def check_company_class_break
# 		Account.current_id = account.id
# 		cclass = CompanyClass.for_daily_calendar(start_at).first
#
# 		if contract.present? && cclass.present?
# 			break_start = cclass.end_at
# 			break_end = break_start + (contract.class_break_min * 60)
#
# 			if break_start <= start_at && start_at < break_end
# 				errors.add(:start_time, "cannot be during the #{contract.class_break_min} min break following the Company Class")
# 			end
# 		end
# 	end
#
# 	def warn_when_emp_over_hrs_per_day
# 		if contract.present?
# 			dancers_above_max = []
#
# 			Person.agma_members.each do |dancer|
# 				#Find rehearsals for specified date
# 				rehearsals = dancer.events.for_daily_calendar(start_at.to_date).where(:events => { :type => 'Rehearsal'})
# 				total_min = 0
# 				rehearsals.each do |rehearsal|
# 					total_min += rehearsal.duration
# 				end
#
# 				dancers_above_max << dancer if total_min > (contract.rehearsal_max_hrs_per_day*60)
# 			end
#
# 			if dancers_above_max.any?
# 				overtime_list = dancers_above_max.map { |emp| emp.full_name }.join(", ")
# 				return "The following people are over their rehearsal limit of #{contract.rehearsal_max_hrs_per_day} hrs/day: "+overtime_list
# 			end
# 		end
# 	end
#
# 	def warn_when_emp_over_hrs_per_week
# 		if contract.present?
# 			dancers_above_max = []
#
# 			Person.agma_members.each do |dancer|
# 				#Find rehearsals for specified date
# 				rehearsals = dancer.events.for_week(start_at.to_date).where(:events => { :type => 'Rehearsal'})
# 				total_min = 0
# 				rehearsals.each do |rehearsal|
# 					total_min += rehearsal.duration
# 				end
# 				dancers_above_max << dancer if total_min > (contract.rehearsal_max_hrs_per_week*60)
# 			end
#
# 			if dancers_above_max.any?
# 				overtime_list = dancers_above_max.map { |emp| emp.full_name }.join(", ")
# 				return "The following people are over their rehearsal limit of #{contract.rehearsal_max_hrs_per_week} hrs/week: "+overtime_list
# 			end
# 		end
# 	end
#
# 	def get_break_record
# 		if contract.present?
# 			rb = contract.rehearsal_breaks.where(duration_min: duration).select('break_min').first
# 			if rb.present?
# 				rb
# 			end
# 		else
# 			return nil
# 		end
# 	end
end
