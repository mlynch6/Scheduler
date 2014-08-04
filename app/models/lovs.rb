class Lovs
	ACTIVE = { "Active" => 1, "Inactive" => 0 }
	CC_MONTHS = [['01 - January', 1], ['02 - February', 2], ['03 - March', 3], ['04 - April', 4],
							 ['05 - May', 5], ['06 - June', 6], ['07 - July', 7], ['08 - August', 8],
						 	 ['09 - September', 9], ['10 - October', 10], ['11 - November', 11], ['12 - December', 12]]
	
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
