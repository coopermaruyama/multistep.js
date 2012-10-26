(($) ->
  $.fn.listenForChange = (options) ->
    settings = $.extend(
      interval: 200 # in microseconds
    , options)
    jquery_object = this
    current_focus = null
    jquery_object.filter(":input").add(":input", jquery_object).focus(->
      current_focus = this
    ).blur ->
      current_focus = null

    setInterval (->
      
      # allow
      jquery_object.filter(":input").add(":input", jquery_object).each ->
        
        # set data cache on element to input value if not yet set
        if $(this).data("change_listener") is `undefined`
          $(this).data "change_listener", $(this).val()
          return
        
        # return if the value matches the cache
        return  if $(this).data("change_listener") is $(this).val()
        
        # ignore if element is in focus (since change event will fire on blur)

        
        # if we make it here, manually fire the change event and set the new value
        $(this).trigger "change"
        $(this).trigger "keyup"
        $(this).data "change_listener", $(this).val()

    ), settings.interval
    this
) jQuery

window.nameinput = #name properties (object)
	maxlength: 35
	lettersonly: true
	regex: /^[a-zA-Z0-9 ]+$/
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
			progressbar: true


		settings = $.extend settings, options

		log = (msg) ->
			console?.log msg if settings.debug

		
		#init
		this.addClass('autovalid-form')
		$('input,select',this).each ->
			$(this).listenForChange()
		this.find('.step').first().css('display','block')
		this.find('.step:not(:first)').append('<a href="#" class="back"></a>');
		window.valid = false
		form = this
		step = $('.step', this)
		currentStep = 0
		specialClasses = ["phone", "zip", "email"]
		window.specialRegEx = new RegExp(specialClasses.join("|"))
		#onchange validation
		$("input:not([type=image],[type=button],[type=submit],[type=radio],[type=checkbox])",form).keyup ->
			min = ($ this).attr('min') ? 3
			if ($ this).attr('class')? and (($ this).attr('class')).match(specialRegEx)? then skip = true
			unless ($ this).attr('optional') is "yes" or ($ this).val().length < min or skip?
				if validateText($(this).val(), min, $(this).attr('max')) then $(this).removeClass('error').addClass('success').attr('valid','true') else $(this).removeClass('success').addClass('error').attr('valid','false')
		($ 'input.phone', form).change ->
			if isPhone($(this).val()) then $(this).removeClass('error').addClass('success').attr('valid','true') else $(this).removeClass('success').addClass('error').attr('valid','false')
		($ 'input.email', form).change ->
			if validateEmail($(this).val()) then $(this).removeClass('error').addClass('success').attr('valid','true') else $(this).removeClass('success').addClass('error').attr('valid','false')
			if $(this).val()? then $(this).addClass('success') else $(this).addClass('error')
		($ 'input.zip', form).change ->
			if is_int($(this).val()) and $(this).val().length is 5 then $(this).removeClass('error').addClass('success').attr('valid','true') else $(this).removeClass('success').addClass('error').attr('valid','false')
			# if $(this).val()? then $(this).addClass('success') else $(this).addClass('error')
		($ 'input[type=radio]', form).change ->
			name = $(this).attr('name')
			if $('input[name='+name+']').is(':checked') then $('.error-text.radio').remove() else $('input[name='+name+']').first().before('<p class="error-text radio">Select an option!</p>')
		($ 'input[type=checkbox]', form).change (e) ->
			min = 1
			max = 9999
			inputName = $(this).prop('name').replace /\[/, "\\["
			inputName = inputName.replace /\]/, "\\]"
			min = $('input[name='+inputName+']').first().attr('min').match(/\d+/) if $('input[name='+inputName+']').first().attr('min')?
			max = $('input[name='+inputName+']').first().attr('max').match(/\d+/) if $('input[name='+inputName+']').first().attr('max')?
			if $('input[name='+inputName+']').is(':checked') and $('input[name=checks]:checked').length <= max and $('input[name=checks]:checked').length >= min
				$('.error-text.checkbox').remove()
			else
				$('.error-text.checkbox').remove()
				$('input[name='+inputName+']').first().before('<p class="error-text checkbox" style="top:'+ ($('input[name='+inputName+']').first().position().top - 20) + 'px;">Select at least ' + min + ' boxes!</p>')
		($ 'select', form).change ->
			if $(this).val()? and ($ this).val() isnt '' then $(this).removeClass('error') else $(this).addClass('error')
		($ 'textarea', form).change ->
			if $(this).val()? and ($ this).val() isnt '' then $(this).removeClass('error').addClass('success').attr('valid', 'true') else $(this).removeClass('success').addClass('error').attr('valid','false')
		#submit button validation
		$('.step .submit', form).click (e) ->
			thisStep = $(this).closest('.step')
			e.preventDefault()
			window.totalitems=0
			window.validitems=0
			#validate textboxes
			$('input:not([type=image],[type=button],[type=submit],[type=radio],[type=checkbox]):visible', thisStep).each ->
				window.totalitems++
				if $(this).attr('valid') is 'true' or ($ this).attr('optional') is "yes"
					window.validitems++
				else
					$(this).removeClass('success').addClass('error').focus()
					false
				log validitems + " " + totalitems
			#validate textarea
			($ 'textarea:visible', thisStep).each ->
				window.totalitems++
				if $(this).attr('valid') is 'true' or ($ this).attr('optional') is "yes"
					window.validitems++
				else
					$(this).removeClass('success').addClass('error').focus()
					false
			#validate select lists
			$('select:visible', thisStep).each ->
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
				if $('input[name='+name+']').is(':checked') or $('input[name='+name+']:hidden').length or $('input[name='+name+'][optional=yes]').length
					window.validitems++ 
				else
					$('.error-text.radio').remove()
					$('input[name='+name+']').first().before('<p class="error-text radio">Select an option!</p>')
				log validitems + " " + totalitems
			# validate checkboxes
			$('input[type=checkbox]', thisStep).each ->
				window.totalitems++
				min = 1
				max = 9999
				inputName = $(this).prop('name').replace /\[/, "\\["
				inputName = inputName.replace /\]/, "\\]"
				min = $('input[name='+inputName+']').first().attr('min').match(/\d+/) if $('input[name='+inputName+']').first().attr('min')?
				max = $('input[name='+inputName+']').first().attr('max').match(/\d+/) if $('input[name='+inputName+']').first().attr('max')?
				name = $(this).attr('name')
				if $('input[name='+inputName+']').is(':checked') and $('input[name=checks]:checked').length <= max and $('input[name=checks]:checked').length >= min or $('input[name='+inputName+']').length #or if any are hidden
					$('.error-text.checkbox').remove()
					window.validitems++
				else
					$('.error-text.checkbox').remove()		
					$('input[name='+inputName+']').first().before('<p class="error-text checkbox" style="top:'+ ($('input[name='+inputName+']').first().position().top - 20) + 'px;">Select at least ' + min + ' boxes!</p>')
				console.log validitems, totalitems
			if window.totalitems is window.validitems
				unless thisStep.attr('id') is "last-step"
					thisStep.slideUp()
					thisStep.next('.step').slideDown()
					currentStep++
					progress = currentStep/($ '.step', form).size()
					$('.progress').css('width', progress*100+"%")
				else 
					form.submit()

		#back button
		$('.back', form).click (e) ->
			e.preventDefault()
			log 'clicked'
			($ this).closest('.step').slideUp()
			($ this).closest('.step').prev('.step').slideDown()	
			currentStep--
			progress = currentStep/($ '.step', form).size()
			$('.progress').css('width', progress*100+"%")





