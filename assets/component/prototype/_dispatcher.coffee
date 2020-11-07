###* Dispatch events ###
dispatch: (event, target, isSync)->
	throw new Error "Expected event type" unless eventName= event.type
	# Generate event path
	eventPath= []
	element= target
	currentElement= @element
	while element and element isnt currentElement
		eventPath.push element
		element= element.parentNode
	# Run
	@__dispatch eventName, event, eventPath, target, isSync, null
	this # chain

# Apply dispatch
__dispatch: (eventName, event, eventPath, target, isSync, wrapper)->
	# Get private attributes
	privateAttr= _componentPrivate.get this
	throw new Error "Unregistred class" unless privateAttr
	# GO THROUGH ELEMENT ATTRIBUTES
	actionAttribute= if isSync then "d-#{eventName}-sync" else "d-#{eventName}"
	for element in eventPath when actionArgs= element.getAttribute actionAttribute
		try
			actionArgs= actionArgs.trim().split /\s+/
			action= actionArgs[0]
			fx= @[action]
			throw "Unknown action: #{action}" unless typeof fx is 'function'
			# Run
			wrappedEvent= new EventWrapper eventName, event, this, element, target, isSync
			if wrapper
				wrapper wrappedEvent, actionArgs
			else
				fx.call this, wrappedEvent, actionArgs
			# BREAK IF STOP_PROPAGATION IS CALLED
			break unless wrappedEvent.bubbles
		catch error
			@emit 'error', err
	# Linked event actions
	if cssWatchers= if isSync then privateAttr.watchSync[eventName] else privateAttr.watch[eventName]
		len= cssWatchers.length
		for element in eventPath
			i= 0
			while i < len
				selector= cssWatchers[i++]
				fx= cssWatchers[i++]
				if element.matches selector
					try
						wrappedEvent= new EventWrapper eventName, event, this, element, target, isSync
						if wrapper
							wrapper wrappedEvent, fx, null
						else
							fx.call this, wrappedEvent, null
						# break if stop immediate bubbles
						break unless wrappedEvent.bubblesImmediate
					catch err
						@emit 'error', err
			# BREAK IF STOP_PROPAGATION IS CALLED
			break unless wrappedEvent.bubbles
	# Execute linked events
	if linkEvents= privateAttr.linkEvents[eventName]
		i= 0
		len= linkEvents.length
		while i < len
			eventName= linkEvents[i++]
			wrapper= linkEvents[i++]
			@__dispatch eventName, event, eventPath, target, isSync, wrapper
	return
###* Load action attributes and wrappers ###
