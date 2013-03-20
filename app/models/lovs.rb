class Lovs
	ACTIVE = { "Active" => 1, "Inactive" => 0 }
	
	def self.time_array(min_increments)
		tm = Time.zone.now.midnight
		@array = []
		while tm < (Time.zone.now.midnight+1.day)
			@array << tm.to_s(:hr12)
			tm += (min_increments).minutes
		end
		
		return @array
	end
end
