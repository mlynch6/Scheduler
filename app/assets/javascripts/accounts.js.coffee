# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
	subscription.setupForm()

subscription =
	setupForm: ->
		$('#new_account').submit ->
			$('input[type=submit]').attr('disabled', true)
			if $('#card_number').length
				subscription.processCard()
				false
			else
				true
	
	processCard: ->
		card =
			number: $('#card_number').val()
			exp_month: $('#card_month').val()
			exp_year: $('#card_year').val()
			cvc: $('#card_code').val()
		Stripe.createToken(card, subscription.handleStripeResponse)
	
	handleStripeResponse: (status, response) ->
		if status == 200
			$('#account_stripe_card_token').val(response.id)
			$('#new_account')[0].submit()
		else
			$('#stripe_error').text(response.error.message)
			$('#stripe_error').css('display', 'block')
			$('input[type=submit]').attr('disabled', false)