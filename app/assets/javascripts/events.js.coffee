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

jQuery ->
	$('#datepicker').datepicker
		dateFormat: "yy-mm-dd",
		defaultDate: paramValue("date"),
		onSelect: (selectedDate, instance) ->
			window.location = "?date="+selectedDate
	#set calendar to show 9AM at top of page
	$('.cal-scrollable').scrollTop(getScrollOffset());