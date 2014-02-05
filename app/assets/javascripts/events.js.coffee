# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
paramValue = (name) ->
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regexS = "[\\?&]" + name + "=([^&#]*)"
  regex = new RegExp(regexS)
  results = regex.exec(window.location.href)
  unless results?
    ""
  else
    results[1]
 
getScrollOffset = () ->
	hour_9AM_in_min = 9*60
	hour_9AM_in_min * 4/3

hideFields = () ->
	switch $('#event_event_type').val()
		when "Event" then $('#piece-field').hide()
		when "CompanyClass" then $('#piece-field').hide()
		when "CostumeFitting" then $('#piece-field').hide()

jQuery ->
	$('#datepicker').datepicker
		dateFormat: "yy/m/d",
		defaultDate: $('#date').val(),
		onSelect: (selectedDate, instance) ->
			window.location = "/events/"+selectedDate
	#set calendar to show 9AM at top of page
	$('.cal-scrollable').scrollTop(getScrollOffset())
	
	# NEW / UPDATE FORMS
	$('#event_start_date').datepicker
		dateFormat: 'mm/dd/yy'
	$('#event_end_date').datepicker
		dateFormat: 'mm/dd/yy'
	$('#event_piece_id').chosen()
	$('#event_employee_ids').chosen()
	hideFields()