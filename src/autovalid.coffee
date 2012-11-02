# tipsy, facebook style tooltips for jquery
# version 1.0.0a
# (c) 2008-2010 jason frame [jason@onehackoranother.com]
# released under the MIT license
(($) ->
  maybeCall = (thing, ctx) ->
    (if (typeof thing is "function") then (thing.call(ctx)) else thing)
  isElementInDOM = (ele) ->
    return true  if ele is document  while ele = ele.parentNode
    false
  Tipsy = (element, options) ->
    @$element = $(element)
    @options = options
    @enabled = true
    @fixTitle()
  Tipsy:: =
    show: ->
      title = @getTitle()
      if title and @enabled
        $tip = @tip()
        $tip.find(".tipsy-inner")[(if @options.html then "html" else "text")] title
        $tip[0].className = "tipsy" # reset classname in case of dynamic gravity
        $tip.remove().css(
          top: 0
          left: 0
          visibility: "hidden"
          display: "block"
        ).prependTo document.body
        pos = $.extend({}, @$element.offset(),
          width: @$element[0].offsetWidth
          height: @$element[0].offsetHeight
        )
        actualWidth = $tip[0].offsetWidth
        actualHeight = $tip[0].offsetHeight
        gravity = maybeCall(@options.gravity, @$element[0])
        tp = undefined
        switch gravity.charAt(0)
          when "n"
            tp =
              top: pos.top + pos.height + @options.offset
              left: pos.left + pos.width / 2 - actualWidth / 2
          when "s"
            tp =
              top: pos.top - actualHeight - @options.offset
              left: pos.left + pos.width / 2 - actualWidth / 2
          when "e"
            tp =
              top: pos.top + pos.height / 2 - actualHeight / 2
              left: pos.left - actualWidth - @options.offset
          when "w"
            tp =
              top: pos.top + pos.height / 2 - actualHeight / 2
              left: pos.left + pos.width + @options.offset
        if gravity.length is 2
          if gravity.charAt(1) is "w"
            tp.left = pos.left + pos.width / 2 - 15
          else
            tp.left = pos.left + pos.width / 2 - actualWidth + 15
        $tip.css(tp).addClass "tipsy-" + gravity
        $tip.find(".tipsy-arrow")[0].className = "tipsy-arrow tipsy-arrow-" + gravity.charAt(0)
        $tip.addClass maybeCall(@options.className, @$element[0])  if @options.className
        if @options.fade
          $tip.stop().css(
            opacity: 0
            display: "block"
            visibility: "visible"
          ).animate opacity: @options.opacity
        else
          $tip.css
            visibility: "visible"
            opacity: @options.opacity


    hide: ->
      if @options.fade
        @tip().stop().fadeOut ->
          $(this).remove()

      else
        @tip().remove()

    fixTitle: ->
      $e = @$element
      $e.attr("original-title", $e.attr("title") or "").removeAttr "title"  if $e.attr("title") or typeof ($e.attr("original-title")) isnt "string"

    getTitle: ->
      title = undefined
      $e = @$element
      o = @options
      @fixTitle()
      title = undefined
      o = @options
      if typeof o.title is "string"
        title = $e.attr((if o.title is "title" then "original-title" else o.title))
      else title = o.title.call($e[0])  if typeof o.title is "function"
      title = ("" + title).replace(/(^\s*|\s*$)/, "")
      title or o.fallback

    tip: ->
      unless @$tip
        @$tip = $("<div class=\"tipsy\"></div>").html("<div class=\"tipsy-arrow\"></div><div class=\"tipsy-inner\"></div>")
        @$tip.data "tipsy-pointee", @$element[0]
      @$tip

    validate: ->
      unless @$element[0].parentNode
        @hide()
        @$element = null
        @options = null

    enable: ->
      @enabled = true

    disable: ->
      @enabled = false

    toggleEnabled: ->
      @enabled = not @enabled

  $.fn.tipsy = (options) ->
    get = (ele) ->
      tipsy = $.data(ele, "tipsy")
      unless tipsy
        tipsy = new Tipsy(ele, $.fn.tipsy.elementOptions(ele, options))
        $.data ele, "tipsy", tipsy
      tipsy
    enter = ->
      tipsy = get(this)
      tipsy.hoverState = "in"
      if options.delayIn is 0
        tipsy.show()
      else
        tipsy.fixTitle()
        setTimeout (->
          tipsy.show()  if tipsy.hoverState is "in"
        ), options.delayIn
    leave = ->
      tipsy = get(this)
      tipsy.hoverState = "out"
      if options.delayOut is 0
        tipsy.hide()
      else
        setTimeout (->
          tipsy.hide()  if tipsy.hoverState is "out"
        ), options.delayOut
    if options is true
      return @data("tipsy")
    else if typeof options is "string"
      tipsy = @data("tipsy")
      tipsy[options]()  if tipsy
      return this
    options = $.extend({}, $.fn.tipsy.defaults, options)
    unless options.live
      @each ->
        get this

    unless options.trigger is "manual"
      binder = (if options.live then "live" else "bind")
      eventIn = (if options.trigger is "hover" then "mouseenter" else "focus")
      eventOut = (if options.trigger is "hover" then "mouseleave" else "blur")
      this[binder](eventIn, enter)[binder] eventOut, leave
    this

  $.fn.tipsy.defaults =
    className: null
    delayIn: 0
    delayOut: 0
    fade: false
    fallback: ""
    gravity: "n"
    html: false
    live: false
    offset: 0
    opacity: 0.8
    title: "title"
    trigger: "hover"

  $.fn.tipsy.revalidate = ->
    $(".tipsy").each ->
      pointee = $.data(this, "tipsy-pointee")
      $(this).remove()  if not pointee or not isElementInDOM(pointee)


  
  # Overwrite this method to provide options on a per-element basis.
  # For example, you could store the gravity in a 'tipsy-gravity' attribute:
  # return $.extend({}, options, {gravity: $(ele).attr('tipsy-gravity') || 'n' });
  # (remember - do not modify 'options' in place!)
  $.fn.tipsy.elementOptions = (ele, options) ->
    (if $.metadata then $.extend({}, options, $(ele).metadata()) else options)

  $.fn.tipsy.autoNS = ->
    (if $(this).offset().top > ($(document).scrollTop() + $(window).height() / 2) then "s" else "n")

  $.fn.tipsy.autoWE = ->
    (if $(this).offset().left > ($(document).scrollLeft() + $(window).width() / 2) then "e" else "w")

  

  $.fn.tipsy.autoBounds = (margin, prefer) ->
    ->
      dir =
        ns: prefer[0]
        ew: ((if prefer.length > 1 then prefer[1] else false))

      boundTop = $(document).scrollTop() + margin
      boundLeft = $(document).scrollLeft() + margin
      $this = $(this)
      dir.ns = "n"  if $this.offset().top < boundTop
      dir.ew = "w"  if $this.offset().left < boundLeft
      dir.ew = "e"  if $(window).width() + $(document).scrollLeft() - $this.offset().left < margin
      dir.ns = "s"  if $(window).height() + $(document).scrollTop() - $this.offset().top < margin
      dir.ns + ((if dir.ew then dir.ew else ""))
) jQuery
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
		$('input[type=text],input[type=email],textarea',this).each ->
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
			if $('input[name='+name+']').is(':checked')
        $('input[name='+name+']').first().tipsy("hide")
		($ 'input[type=checkbox]', form).change (e) ->
			min = 1
			max = 9999
			inputName = $(this).prop('name').replace /\[/, "\\["
			inputName = inputName.replace /\]/, "\\]"
			min = $('input[name='+inputName+']').first().attr('min').match(/\d+/) if $('input[name='+inputName+']').first().attr('min')?
			max = $('input[name='+inputName+']').first().attr('max').match(/\d+/) if $('input[name='+inputName+']').first().attr('max')?
			if $('input[name='+inputName+']').is(':checked') and $('input[name='+inputName+']:checked').length <= max and $('input[name='+inputName+']:checked').length >= min
        $('input[name='+inputName+']').first().tipsy("hide")
        $('input[name='+inputName+']').first().tipsy("hide")
			else
				$('.error-text.checkbox').remove()
				$('input[name='+inputName+']').first().attr('original-title','Select at least ' + min + ' boxes!').tipsy("show")
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
			$('input[type=radio]:visible', thisStep).each ->
				name = $(this).attr('name')
				window.totalitems++
				if $('input[name='+name+']').is(':checked') or $('input[name='+name+']:hidden').length or $('input[name='+name+'][optional=yes]').length
					window.validitems++ 
				else
					$('input[name='+name+']').first().attr('original-title','Select One!')
					$('input[name='+name+']').first().tipsy({trigger:'manual',gravity:'e'})
					$('input[name='+name+']').first().tipsy("show")
			# validate checkboxes
			$('input[type=checkbox]:visible', thisStep).each ->
				window.totalitems++
				min = 0
				max = 9999
				inputName = $(this).prop('name').replace /\[/, "\\["
				inputName = inputName.replace /\]/, "\\]"
				min = $('input[name='+inputName+']').first().attr('min').match(/\d+/) if $('input[name='+inputName+']').first().attr('min')?
				max = $('input[name='+inputName+']').first().attr('max').match(/\d+/) if $('input[name='+inputName+']').first().attr('max')?
				name = $(this).attr('name')
				if $('input[name='+inputName+']').is(':checked') and $('input[name='+inputName+']:checked').length <= max and $('input[name='+inputName+']:checked').length >= min
					$('input[name='+inputName+']').first().tipsy("hide")
					window.validitems++
				else
					$('input[name='+inputName+']').first().attr('original-title','Select at least ' + min + ' boxes!').tipsy("show")
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
$ ->
	$('input:not([type=button],[type=image],[type=submit],[type=radio],[type=checkbox]),select').each ->
		$(this).tipsy({trigger: 'manual', gravity: 'w', fallback: 'fix this field!'})
	$('input[type=checkbox]').each ->
		$(this).tipsy({trigger: 'manual', gravity: 'se', fallback: 'Select one!'})



