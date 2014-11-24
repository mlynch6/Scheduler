# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('#lecture_demo_start_date').datepicker("option", "minDate", $('#season_start_date').html())
  $('#lecture_demo_start_date').datepicker("option", "maxDate", $('#season_end_date').html())