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

class CompanyClass < Event
	before_validation :default_title

	validate :check_contracted_start, :if => "start_time.present?"
	validate :check_contracted_end, :if => "end_time.present?"
	validate :check_duration_increments, :if => "start_at.present? && end_at.present?"

	def break_duration
		profile.class_break_min if profile.present?
	end
	
	def break_time
		if profile.present?
			break_end = end_at + break_duration*60
			return "#{end_at.to_s(:hr12)} to #{break_end.to_s(:hr12)}"
		end
	end
	
protected	
	def default_title
		self.title = "Company Class" if title.empty?
	end

	def check_contracted_start
		if profile.present?
			contracted_start = profile.rehearsal_start_time
			
			if Time.zone.parse(contracted_start) > Time.zone.parse(start_time.to_s(:hr12))
				errors.add(:start_time, "must be on or after the contracted start time of #{contracted_start}")
			end
		end
	end
	
	def check_contracted_end
		if profile.present?
			contracted_end = profile.rehearsal_end_time
			
			if Time.zone.parse(contracted_end) < Time.zone.parse(end_time.to_s(:hr12))
				errors.add(:end_time, "must be on or before the contracted end time of #{contracted_end}")
			end
		end
	end
	
	def check_duration_increments
		if profile.present?
			contract_increment_min = profile.rehearsal_increment_min
			duration_min = (end_at - start_at) / 60
			
			if duration_min.remainder(contract_increment_min) != 0
				errors.add(:duration, "must be in increments of #{contract_increment_min} minutes")
			end
		end
	end
end
