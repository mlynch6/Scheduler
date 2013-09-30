# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
	$('#season_start_dt').datepicker
		dateFormat: 'mm/dd/yy'
	$('#season_end_dt').datepicker
		dateFormat: 'mm/dd/yy'
	$('#season_piece_ids').chosen()