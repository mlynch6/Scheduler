# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
	$('#rehearsal_start_date').datepicker
		dateFormat: 'mm/dd/yy'
	$('#rehearsal_employee_ids').chosen()