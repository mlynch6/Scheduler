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
	$('#event_start_date').datepicker
		dateFormat: 'mm/dd/yy'
	$('#event_end_date').datepicker
		dateFormat: 'mm/dd/yy'
	$('#event_piece_id').chosen()
	$('#event_employee_ids').chosen()
	hideEventFields()
	hideRepeatingFields()
	$('.mash-no-confirm').removeAttr('data-confirm')
	
	$('#event_period').change ->
		hideRepeatingFields()
	
	# INDEX
	$('#calendar').fullCalendar
		defaultView:	'agendaDay'
		theme: 				true
		editable:			false
		allDaySlot:		false
		allDayDefault: false
		firstHour:		8
		slotMinutes: 	15
		height: 			650
		timeFormat: 	'h:mm TT{ - h:mm TT} '
		ignoreTimezone: false
		year:					$('#calendar').data('year')
		month:				$('#calendar').data('month')-1
		date:					$('#calendar').data('day')
		titleFormat:
    	month: 			'MMMM yyyy'
    	week: 			"MMMM d[ yyyy]{ '&#8212;'[ MMMM] d, yyyy}"
    	day: 				'MMMM d, yyyy'
    columnFormat:
    	month:			'ddd'
    	week:				'ddd d'
    	day: 				'dddd'
    header:
    	left: 			'prev today next'
    	center: 		'title'
    	right: 			'agendaDay agendaWeek month'
		buttonText:
			today: 			'Today'
			month: 			'Month'
			week: 			'Week'
			day: 				'Day'
		events: "/events"
		eventAfterRender: (event, element) ->
			if event.location
				element.find('.fc-event-title').after("<div class=\"fc-event-location\">"+event.location+"</div>")
		eventClick: (calEvent, jsEvent) ->
			$("#eventDialog").load("/events/"+calEvent.id+".js",
				(response, status, xhr) ->
					$("#eventModal").modal('show') )