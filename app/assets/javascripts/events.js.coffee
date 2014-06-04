# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

hideEventFields = () ->
	switch $('#event_event_type').val()
		when "Event" then $('#piece-field').hide()
		when "CompanyClass" then $('#piece-field').hide()
		when "CostumeFitting" then $('#piece-field').hide()

hideRepeatingFields = () ->
	switch $('#event_period').val()
		when "Never" then $('#repeat-fields').hide()
		else $('#repeat-fields').show()

jQuery ->
	# NEW / UPDATE FORMS
	hideEventFields()
	hideRepeatingFields()
	$('.mash-no-confirm').removeAttr('data-confirm')
	
	$('#event_period').change ->
		hideRepeatingFields()
	
	# INDEX
	$('#calendar').fullCalendar
		defaultView:		'agendaDay'
		theme: 				true
		editable:			false
		allDaySlot:		false
		allDayDefault: false
		firstHour:			8
		slotMinutes: 	15
		height: 				650
		timeFormat: 
			month:				'h(:mm) TT'
			agenda:			'h(:mm) TT{ - h(:mm) TT}'
		ignoreTimezone: false
		year:					$('#calendar').data('year')
		month:					$('#calendar').data('month')-1
		date:					$('#calendar').data('day')
		titleFormat:
			month: 		'MMMM yyyy'
			week: 			"MMMM d[ yyyy]{ '&#8212;'[ MMMM] d, yyyy}"
			day: 			'MMMM d, yyyy'
		columnFormat:
			month:			'ddd'
			week:			'ddd d'
			day: 			'dddd'
		header:
			left: 			'prev today next'
			center: 		'title'
			right: 		'agendaDay agendaWeek'
		buttonText:
			today: 		'Today'
			month: 		'Month'
			week: 			'Week'
			day: 			'Day'
		events: "/events"
		eventAfterRender: (event, element, view) ->
			if (view.name != 'month' && event.location)
				element.find('.fc-event-title').after("<div class=\"fc-event-location\">"+event.location+"</div>")
		eventClick: (calEvent, jsEvent) ->
			$("#eventDialog").load("/events/"+calEvent.id+".js",
				(response, status, xhr) ->
					$("#eventModal").modal('show') )
		dayClick: (calDate, allDay, jsEvent, view) ->
			date = (calDate.getMonth()+1)+"-"+calDate.getDate()+"-"+calDate.getFullYear()
			
			hr = calDate.getHours().toString()
			if hr.length < 2 then hr = '0'+hr
			min = calDate.getMinutes().toString()
			if min == '0' then min = '00'
			time24 = hr+min
			
			$('#dt').val(date)
			if view.name == "month"
				$('#tm').val('')
			else
				$('#tm').val(time24)
			$('#newModal').modal('show')