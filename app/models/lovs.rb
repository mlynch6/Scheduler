class Lovs
	ACTIVE = { "Active" => 1, "Inactive" => 0 }
	
	def self.time_array(min_increments)
		tm = Time.now.midnight
		mins = 0
		@array = Hash.new
		while mins < 1440
			@array[(tm + mins.minutes).to_s(:hr12)] = mins
			mins += min_increments
		end
		
		return @array
	end
end
