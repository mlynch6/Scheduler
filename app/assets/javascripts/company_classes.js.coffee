# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('#company_class_start_date').datepicker("option", { onClose: (selectedDate) -> $('#company_class_end_date').datepicker("option", "minDate", selectedDate) })
  $('#company_class_start_date').datepicker("option", "minDate", $('#season_start_date').html())
  $('#company_class_start_date').datepicker("option", "maxDate", $('#season_end_date').html())
  $('#company_class_end_date').datepicker("option", "minDate", $('#season_start_date').html())
  $('#company_class_end_date').datepicker("option", "maxDate", $('#season_end_date').html())
  $('#company_class_end_date').datepicker("option", { onClose: (selectedDate) -> $('#company_class_start_date').datepicker("option", "maxDate", selectedDate) })