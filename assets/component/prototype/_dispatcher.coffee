###* Dispatch events ###
dispatch: (event, target, isSync)->
	throw new Error "Expected event type" unless eventName= event.type
	# Generate event path
	eventPath= []
	element= target
	currentElement= @element
	while element and element isnt currentElement
		eventPath.push element
		element= element.parentElement
	# Run
	@__dispatch eventName, event, eventPath, target, isSync
	this # chain

# Apply dispatch
__dispatch: (eventName, event, eventPath, target, isSync)->
	# Get private attributes
	privateAttr= _componentPrivate.get @constructor
	throw new Error "Unregistred class" unless privateAttr
	wrapper= privateAttr.eventWrapper[eventName]
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
		catch err
			@emit 'error', err.stack or error
	# Linked event actions
	if cssWatchers= (if isSync then privateAttr.watchSync[eventName] else privateAttr.watch[eventName])
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
		for customEvnt in linkEvents
			@__dispatch customEvnt, event, eventPath, target, isSync
	return

###* Load action attributes and wrappers ###
