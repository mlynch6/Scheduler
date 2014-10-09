json.array! @events do |event|
	json.id 				event.id
	json.type 			event.type
	json.title 			event.title
	json.allDay 		false
	json.start 			event.start_at.iso8601
	json.end 				event.end_at.iso8601
	case (event.type)
		when "CompanyClass"
			json.className 	'mash-event cal-red'
		when "CostumeFitting"
			json.className 	'mash-event cal-green'
		when "Rehearsal"
			json.className 	'mash-event cal-blue'
		else
			json.className 	'mash-event cal-brown'
	end
	json.location 	event.location.name
end