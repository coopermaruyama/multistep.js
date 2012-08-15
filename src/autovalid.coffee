#eventually validate name, phone, email

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

$ ->
	#init vars
	window.valid = false
	form = $('#form')
	input = '#form > .step input'
	#onchange validation
	($ input+'[type=text],'+input+'[type=password],'+input+'[type=email]').change ->
		unless ($ this).attr('optional') is "yes"
			if validateText($(this).val(), $(this).attr('min'), $(this).attr('max')) then $(this).removeClass('error').addClass('success').attr('valid','true') else $(this).removeClass('success').addClass('error').attr('valid','false')
	($ input+'.phone').change ->
		if isPhone($(this).val()) then $(this).removeClass('error').addClass('success').attr('valid','true') else $(this).removeClass('success').addClass('error').attr('valid','false')
	($ input+'.email').change ->
		if validateEmail($(this).val()) then $(this).removeClass('error').addClass('success').attr('valid','true') else $(this).removeClass('success').addClass('error').attr('valid','false')
		if $(this).val()? then $(this).addClass('success') else $(this).addClass('error')
	($ input+'[type=radio]').change ->
		name = $(this).attr('name')
		if $('input[name='+name+']').is(':checked') then $('.error-text.radio').remove() else $('input[name='+name+']').first().before('<p class="error-text radio">Select an option!</p>')
	($ input+'[type=checkbox]').change (e) ->
		min = 1
		max = 9999
		min = $('input[name='+$(this).prop('name')+']').first().attr('min').match(/\d+/) if $('input[name='+$(this).prop('name')+']').first().attr('min')?
		max = $('input[name='+$(this).prop('name')+']').first().attr('max').match(/\d+/) if $('input[name='+$(this).prop('name')+']').first().attr('max')?
		if $('input[name='+$(this).prop('name')+']').is(':checked') and $('input[name=checks]:checked').length <= max and $('input[name=checks]:checked').length >= min
			$('.error-text.checkbox').remove()
		else
			$('.error-text.checkbox').remove()		
			$('input[name='+$(this).prop('name')+']').first().before('<p class="error-text checkbox">Select at least ' + min + ' boxes!</p>')
	($ '#form > .step select').change ->
		if $(this).val()? and ($ this).val() isnt '' then $(this).removeClass('error') else $(this).addClass('error')
	#submit button validation
	$('#form > .step .submit').click (e) ->
		thisStep = $(this).parent()
		e.preventDefault()
		window.totalitems=0
		window.validitems=0
		#validate textboxes
		thisStep.children(input+'[type=text],'+input+'[type=password],'+input+'[type=email]').each ->
			window.totalitems++
			if $(this).attr('valid') is 'true' or ($ this).attr('optional') is "yes"
				window.validitems++
			else
				$(this).removeClass('success').addClass('error').focus()
				false
			console.log validitems, totalitems
		#validate select lists
		thisStep.children('select').each ->
			window.totalitems++
			if $(this).val()? and $(this).val() isnt ""
				window.validitems++ 
				$(this).removeClass('error')
			else
				$(this).addClass('error')
		# validate radio
		thisStep.children('input[type=radio]').each ->
			name = $(this).attr('name')
			window.totalitems++
			if $('input[name='+name+']').is(':checked')
				window.validitems++ 
			else
				$('.error-text.radio').remove()
				$('input[name='+name+']').first().before('<p class="error-text radio">Select an option!</p>')
			console.log validitems, totalitems
		# validate checkboxes
		thisStep.children('input[type=checkbox]').each ->
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
				($ '#form').submit()





