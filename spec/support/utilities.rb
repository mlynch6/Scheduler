module Utilities
	#Input: number of minutes past midnight
	#Output: formatted time
  def min_to_formatted_time(mnt)
		(Time.now.midnight + mnt.minutes).to_s(:hr12)
	end
	
	def open_modal(*args)
		find(*args).click
		wait_until { find(".modal-dialog").visible? }
	end
end