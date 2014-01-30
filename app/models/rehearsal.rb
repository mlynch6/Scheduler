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

class Rehearsal < Event
	belongs_to :piece
	
	validate :check_contracted_start, :if => "start_time.present?"
	validate :check_contracted_end, :if => "start_time.present? && duration.present?"
	validate :check_duration_increments, :if => "start_at.present? && end_at.present?"
	validate :check_company_class_break, :if => "start_date.present? && start_time.present?"
	validates :piece_id,	presence: true

	def break_duration
		contract.rehearsal_break_min_per_hr if contract.present?
	end
	
	def break_time
		if contract.present?
			break_start = end_at - break_duration*60
			return "#{break_start.to_s(:hr12)} to #{end_at.to_s(:hr12)}"
		end
	end
	
protected
	
	def check_duration_increments
		if contract.present? && duration.remainder(contract.rehearsal_increment_min) != 0
			errors.add(:duration, "must be in increments of #{contract.rehearsal_increment_min} minutes")
		end
	end
	
	#Rehearsal cannot start during the break following the company class
	def check_company_class_break
		cclass = CompanyClass.for_daily_calendar(start_date).first
		
		if contract.present? && cclass.present?
			break_start = cclass.end_at
			break_end = break_start + (contract.class_break_min * 60)
			
			if break_start <= start_at && start_at < break_end
				errors.add(:start_time, "cannot be during the #{contract.class_break_min} min break following the Company Class")
			end
		end
	end
end
