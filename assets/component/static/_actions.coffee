###*
 * Actions
 * @example
 * component.enableAction 'click'
###
@enableAction: (eventName)-> @__enableNativeEvent arguments, no
@enableSyncAction: (eventName)-> @__enableNativeEvent arguments, yes
@__enableNativeEvent: do ->
	_syncListeners= {}		# Map sync events
	_asyncListeners= {}		# Map async events
	# Create listener
	_dispatch= (isSync, event)->
		throw new Error "Expected event type" unless eventName= event.type
		target= element= event.target
		eventPath= []
		unless element in [window, document]
			# Run components
			while element
				# Check for component
				if componentClass= _components.get element.tagName
					component= element[COMPONENT_SYMB] or new componentClass(element)
					component.__dispatch eventName, event, eventPath, target, isSync, null
					target= element
					eventPath.length= 0
				# next
				eventPath.push element
				element= element.parentElement
		# Run global component
		ROOT_COMPONENT.__dispatch eventName, event, eventPath, target, isSync, null
		return
	# Interface
	(events, isSync)->
		for eventName in events
			# Check
			throw new Error '::enableAction>> Illegal eventName' unless typeof eventName is 'string' and EVENT_NAME_REGEX.test eventName
			# Get native event
			ref= eventName
			ref2= eventName
			privateAttr= _componentPrivate.get this
			customEvents= privateAttr.customEvents
			while ref= customEvents[ref]
				throw "Event link circle detected for event: #{eventName}" if ref is eventName
				ref2= ref
			eventName= ref2
			# Add event listener
			listeners= if isSync then _syncListeners else _asyncListeners
			unless listeners[eventName]
				listeners[eventName]= listener= _dispatch.bind null, isSync
				window.addEventListener eventName, listener, {capture: true, passive: !isSync}
		# Chain
		this
