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

class CompanyClass < Event
	before_validation :default_title

	validate :check_contracted_start, :if => "start_time.present?"
	validate :check_contracted_end, :if => "start_time.present? && duration.present?"
	validate :check_duration_increments, :if => "start_at.present? && end_at.present?"

	def break?
		true
	end
	
	def break_duration
		contract.class_break_min if contract.present?
	end
	
	def break_time
		if contract.present?
			break_end = end_at + break_duration*60
			return "#{end_at.to_s(:hr12)} to #{break_end.to_s(:hr12)}"
		end
	end
	
protected	
	def default_title
		self.title = "Company Class" if title.blank?
	end
	
	def check_duration_increments
		if contract.present? && duration.remainder(contract.rehearsal_increment_min) != 0
			errors.add(:duration, "must be in increments of #{contract.rehearsal_increment_min} minutes")
		end
	end
end
