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

class CostumeFitting < Event
	before_validation :default_title

	validate :check_duration_increments, :if => "start_at.present? && end_at.present?"
	
protected	
	def default_title
		self.title = "Costume Fitting" if title.empty?
	end
	
	def check_duration_increments
		if profile.present?
			contract_increment_min = profile.costume_increment_min
			duration_min = (end_at - start_at) / 60
			
			if duration_min.remainder(contract_increment_min) != 0
				errors.add(:duration, "must be in increments of #{contract_increment_min} minutes")
			end
		end
	end
end