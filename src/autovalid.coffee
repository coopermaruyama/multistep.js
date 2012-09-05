
window.nameinput = #name properties (object)
	maxlength: 35
	lettersonly: true
	regex: /^[a-zA-Z ]+$/
	notblank: true

window.emailinput =
	malength: 35
	regex: /^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$/

window.isblank = (str) -> if str.length == 0 then true else false #check blank-ness

window.tooLong = (string, maxlength) -> if string.length <= maxlength then false else true

window.tooShort = (string, minlength) -> if string.length >= minlength then false else true

window.validateText = (text, min, max) ->
	validitems = 0
	totalitems = 4
	min = 3 unless min?
	max = 35 unless max?
	increment = -> validitems++
	increment() if !isblank(text)
	increment() if !tooShort(text, min)
	increment() if !tooLong(text, max)
	increment() if nameinput.regex.test(text)
	if validitems < totalitems then false else true
	
window.validateEmail = (email) ->
	validitems = 0
	totalitems = 1
	increment = -> validitems++
	increment() if emailinput.regex.test(email)
	if validitems < totalitems then false else true

window.isPhone = (input) ->
	regex = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})\s*[-. ]?\s*([0-9]{4})$/
	regex.test(input)

window.is_int = (value) ->
	if parseFloat(value) is parseInt(value) and !isNaN(value) then true else false

$ = jQuery

$.fn.extend
	autoValid: (options) ->

		settings = #add settings
			debug: true

		settings = $.extend settings, options

		log = (msg) ->
			console?.log msg if settings.debug
		#init vars
		window.valid = false
		form = this
		step = $('.step', this)
		#onchange validation
		$("input:not([type=image],[type=button],[type=submit],[type=radio],[type=checkbox])",form).keyup ->
			min = ($ this).attr('min') ? 3
			unless ($ this).attr('optional') is "yes" or ($ this).val().length < min
				if validateText($(this).val(), min, $(this).attr('max')) then $(this).removeClass('error').addClass('success').attr('valid','true') else $(this).removeClass('success').addClass('error').attr('valid','false')
		($ 'input.phone', form).change ->
			if isPhone($(this).val()) then $(this).removeClass('error').addClass('success').attr('valid','true') else $(this).removeClass('success').addClass('error').attr('valid','false')
		($ 'input.email', form).change ->
			if validateEmail($(this).val()) then $(this).removeClass('error').addClass('success').attr('valid','true') else $(this).removeClass('success').addClass('error').attr('valid','false')
			if $(this).val()? then $(this).addClass('success') else $(this).addClass('error')
		($ 'input[type=radio]', form).change ->
			name = $(this).attr('name')
			if $('input[name='+name+']').is(':checked') then $('.error-text.radio').remove() else $('input[name='+name+']').first().before('<p class="error-text radio">Select an option!</p>')
		($ 'input[type=checkbox]', form).change (e) ->
			min = 1
			max = 9999
			min = $('input[name='+$(this).prop('name')+']').first().attr('min').match(/\d+/) if $('input[name='+$(this).prop('name')+']').first().attr('min')?
			max = $('input[name='+$(this).prop('name')+']').first().attr('max').match(/\d+/) if $('input[name='+$(this).prop('name')+']').first().attr('max')?
			if $('input[name='+$(this).prop('name')+']').is(':checked') and $('input[name=checks]:checked').length <= max and $('input[name=checks]:checked').length >= min
				$('.error-text.checkbox').remove()
			else
				$('.error-text.checkbox').remove()		
				$('input[name='+$(this).prop('name')+']').first().before('<p class="error-text checkbox">Select at least ' + min + ' boxes!</p>')
		($ 'select', form).change ->
			if $(this).val()? and ($ this).val() isnt '' then $(this).removeClass('error') else $(this).addClass('error')
		#submit button validation
		$('.step .submit', form).click (e) ->
			thisStep = $(this).closest('.step')
			e.preventDefault()
			window.totalitems=0
			window.validitems=0
			#validate textboxes
			$('input:not([type=image],[type=button],[type=submit],[type=radio],[type=checkbox])', thisStep).each ->
				window.totalitems++
				if $(this).attr('valid') is 'true' or ($ this).attr('optional') is "yes"
					window.validitems++
				else
					$(this).removeClass('success').addClass('error').focus()
					false
				console.log validitems, totalitems
			#validate select lists
			$('select', thisStep).each ->
				window.totalitems++
				if $(this).val()? and $(this).val() isnt ""
					window.validitems++ 
					$(this).removeClass('error')
				else
					$(this).addClass('error')
			# validate radio
			$('input[type=radio]', thisStep).each ->
				name = $(this).attr('name')
				window.totalitems++
				if $('input[name='+name+']').is(':checked')
					window.validitems++ 
				else
					$('.error-text.radio').remove()
					$('input[name='+name+']').first().before('<p class="error-text radio">Select an option!</p>')
				console.log validitems, totalitems
			# validate checkboxes
			$('input[type=checkbox]', thisStep).each ->
				window.totalitems++
				min = 1
				max = 9999
				min = $('input[name='+$(this).prop('name')+']').first().attr('min').match(/\d+/) if $('input[name='+$(this).prop('name')+']').first().attr('min')?
				max = $('input[name='+$(this).prop('name')+']').first().attr('max').match(/\d+/) if $('input[name='+$(this).prop('name')+']').first().attr('max')?
				name = $(this).attr('name')
				if $('input[name='+$(this).prop('name')+']').is(':checked') and $('input[name=checks]:checked').length <= max and $('input[name=checks]:checked').length >= min
					$('.error-text.checkbox').remove()
					window.validitems++
				else
					$('.error-text.checkbox').remove()		
					$('input[name='+$(this).prop('name')+']').first().before('<p class="error-text checkbox">Select at least ' + min + ' boxes!</p>')
				console.log validitems, totalitems
			if window.totalitems is window.validitems
				unless thisStep.attr('id') is "last-step"
					thisStep.slideUp()
					thisStep.next('.step').slideDown()
				else 
					form.submit()





