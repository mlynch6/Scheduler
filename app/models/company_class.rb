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
	validate :check_contracted_start, :if => "start_time.present?"
	validate :check_contracted_end, :if => "end_time.present?"
	validate :check_duration_increments, :if => "start_at.present? && end_at.present?"

protected	
	def check_contracted_start
		contracted_start = AgmaProfile.find_by_account_id(Account.current_id).rehearsal_start_time
		
		if Time.zone.parse(contracted_start) > Time.zone.parse(start_time.to_s(:hr12))
			errors.add(:start_time, "must be on or after the contracted start time of #{contracted_start}")
		end
	end
	
	def check_contracted_end
		contracted_end = AgmaProfile.find_by_account_id(Account.current_id).rehearsal_end_time
		
		if Time.zone.parse(contracted_end) < Time.zone.parse(end_time.to_s(:hr12))
			errors.add(:end_time, "must be on or before the contracted end time of #{contracted_end}")
		end
	end
	
	def check_duration_increments
		contract_increment_min = AgmaProfile.find_by_account_id(Account.current_id).rehearsal_increment_min
		duration_min = (end_at - start_at) / 60
		
		if duration_min.remainder(contract_increment_min) != 0
			errors.add(:duration, "must be in increments of #{contract_increment_min} minutes")
		end
	end
end
