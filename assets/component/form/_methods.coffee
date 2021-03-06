# Apply operations on focus
vFocus: (event)->
	input= event.target
	# Remove flags
	if fCntrl= input.closest '.f-cntrl'
		requestAnimationFrame =>
			# Remove state classes
			# fCntrl.classList.remove 'has-error', 'has-done', 'has-warn'
			# Reset active input
			for element in fCntrl.querySelectorAll('.active-input')
				element.classList.remove 'active-input'
			# Set current input as active
			input.classList.add 'active-input'
			fCntrl.classList.add 'has-active'
			return
	# Auto-select
	input.select() if input.hasAttribute 'd-select'
	# Autocomplete
	if input.hasAttribute 'd-autocomplete'
		@autocomplete event, [null, input.getAttribute 'd-autocomplete']
	return

###* Validate form control ###
vFormControl: (input)->
	input[INPUT_VALIDATED]= no
	# Remove state classes
	if fCntrl= input.closest '.f-cntrl'
		fCntrlClass= fCntrl.classList
		requestAnimationFrame ->
			fCntrlClass.remove 'has-error', 'has-done', 'has-warn', 'has-active'
			fCntrlClass.add 'loading'
			return
	# Validate
	state= false
	addClass= null
	try
		value= input.value
		# Check it's a valid html input
		if attributes= input.getAttributeNames?()
			# Execute validation methods prefexed with 'v-'
			for attrName in attributes when attrName.startsWith('v-') and handler= @[attrName]
				value= await handler.call this, value, input.getAttribute(attrName), input
			# Required
			if input.hasAttribute 'required'
				value= await @['v-required'] value, null, input
			# Pattern
			if input.hasAttribute 'pattern'
				value= await @['v-regex'] value, input.getAttribute('pattern'), input
			if input.hasAttribute 'step'
				value= await @['v-step'] value, input.getAttribute('step'), input
			if input.hasAttribute 'min'
				value= await @['v-min'] value, input.getAttribute('min'), input
			if input.hasAttribute 'max'
				value= await @['v-max'] value, input.getAttribute('max'), input
			# replace with new value
			if input.type isnt 'file'
				input.value= value
			# Has success
			addClass= 'has-done' if input.value isnt input.defaultValue
			input[INPUT_VALIDATED]= yes
			state= yes
	catch err
		if err is 'warn'
			addClass= 'has-warn'
		else
			addClass= 'has-error'
			if err isnt false
				@emit 'error', {element: input, error: err}
		@animateInputError input
	finally
		# trigger validation state
		@emit 'validated',
			element:	input
			status:		state
		if fCntrlClass
			requestAnimationFrame ->
				fCntrlClass.remove 'loading'
				fCntrlClass.add addClass if addClass
				unless state
					fCntrl.scrollIntoViewIfNeeded()
				return
	return state

# Apply reset
vRest: (event)->
	form= event.target
	# remove state classes
	requestAnimationFrame ->
		for element in form.querySelectorAll('.has-error, .has-done, .has-warn')
			element.classList.remove 'has-error', 'has-done', 'has-warn'
		return
	# empty file upload queue
	for element in form.querySelectorAll 'input[type="file"]'
		queue.length= 0 if queue= element[FILE_LIST_SYMB]
		@filePreviewReset element
	return

# Apply submit
vSubmit: (event)->
	# Prepare
	form= event.target
	requestAnimationFrame ->
		fcl= form.classList
		fcl.remove 'form-has-error'
		fcl.add 'loading'
		return
	try
		# Prevent sending
		event.preventDefault()
		# Validate form
		jobs= []
		formElements= form.elements
		for element in formElements
			if element.disabled
				jobs.push yes
			else if (state= element[INPUT_VALIDATED])?
				jobs.push state
			else
				jobs.push _closestComponent(element).vFormControl element
		jobs= await Promise.all jobs
		for v,i in jobs when v is no
			# do animation
			input= formElements[i]
			input.focus()
			input.select()
			@animateInputError input
			throw no
		# Callbacks before submit on elements
		for element in formElements when not element.disabled and (attr= element.getAttribute 'v-submit')
			parts= attr.trim().split /[\s,]+/
			cb= @[parts[0]]
			throw new Error "Unknown method for submit: #{parts[0]}" unless typeof cb is 'function'
			await cb.call this, element, parts
		# Check for cb
		if attr= form.getAttribute 'v-submit'
			parts= attr.trim().split /[\s,]+/
			cb= @[parts[0]]
			throw new Error "Unknown method for submit: #{parts[0]}" unless typeof cb is 'function'
			await cb.call this, event, parts
		else
			form.submit()
	catch err
		unless (err is no) or (err?.aborted) # err.aborted => ajax
			@emit 'error', err
			requestAnimationFrame ->
				form.classList.add 'form-has-error'
				return
	finally
		requestAnimationFrame ->
			form.classList.remove 'loading'
			return
	return

# Execute an animation for input when error
animateInputError: (input)->
	input.animate({
		color: ['transparent', 'inherit']
	},{
		easing:		'steps(2, start)'
		duration:	1000
		iterations:	3
	})
	return
