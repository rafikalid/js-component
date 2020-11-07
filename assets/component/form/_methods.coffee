# Apply operations on focus
vFocus: (event)->
	input= event.target
	# Remove flags
	if fCntrl= input.closest '.f-cntrl'
		# Remove state classes
		_removeClasses fCntrl, 'has-error', 'has-done', 'has-warn'
		# Reset active input
		for element in fCntrl.querySelectorAll('.active-input')
			element.classList.delete 'active-input'
		# Set current input as active
		input.classList.add 'active-input'
		fCntrl.classList.add 'has-active'
	# Auto-select
	input.select() if input.hasAttribute 'd-select'
	# Autocomplete
	# TODO: autocomplete
	# if args= element.getAttribute 'd-autocomplete'
	# 	_closestComponent(element).autocomplete element, args
	return

###* Validate form control ###
vFormControl: (input)->
	input[INPUT_VALIDATED]= no
	# Remove state classes
	if fCntrl= input.closest '.f-cntrl'
		_removeClasses fCntrl, 'has-error', 'has-done', 'has-warn', 'has-active'
		fCntrlClass= fCntrl.classList
		fCntrlClass.add 'loading'
	# Validate
	state= false
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
			input.value= value if input.type isnt 'file'
			# Has success
			fCntrlClass?.add 'has-done' if input.value isnt input.defaultValue
			input[INPUT_VALIDATED]= yes
			state= yes
	catch err
		fCntrlClass?.add if err is 'warn' then 'has-warn' else 'has-error'
		@emit 'form-error', {element: input, error: err}
	finally
		fCntrlClass?.delete 'loading'
		# trigger validation state
		@emit 'validated',
			element:	input
			status:		state
	return state

# Apply reset
vRest: (event)->
	form= event.target
	# remove state classes
	elements= form.querySelectorAll('.has-error, .has-done, .has-warn')
	_removeElementsClasses elements, 'has-error', 'has-done', 'has-warn'
	# empty file upload queue
	for element in form.querySelectorAll 'input[type="file"]'
		queue.length= 0 if queue= element[FILE_LIST_SYMB]
		@filePreviewReset element
	return

# Apply submit
vSubmit: (event)->
	# Prepare
	form= event.target
	form.classList.add 'loading'
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
				jobs.push @vFormControl element
		jobs= await Promise.all jobs
		for v,i in jobs when v is no
			# do animation
			@animateInputError formElements[i]
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
	catch error
		unless (err is no) or (err?.aborted) # err.aborted => ajax
			$form.addClass 'form-has-error'
			@emit 'form-error', err
	finally
		form.classList.delete 'loading'
	return

# Execute an animation for input when error
animateInputError: (input)->
	# TODO: add an animation & beep in Core-ui
	# Select
	input.focus()
	input.select()
	return
