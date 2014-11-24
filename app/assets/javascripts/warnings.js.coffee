# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('#warnings_report_search #start_date').datepicker("option", { onClose: (selectedDate) -> $('#warnings_report_search #end_date').datepicker("option", "minDate", selectedDate) })
  $('#warnings_report_search #end_date').datepicker("option", { onClose: (selectedDate) -> $('#warnings_report_search #start_date').datepicker("option", "maxDate", selectedDate) })