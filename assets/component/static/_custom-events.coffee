 ###*
 * Custom events
 * @example
 * ::createEvent('hover', 'mouseover',  function(event, listener, args){})
###
@createEvent: (customEvent, srcEvent, wrapper)->
	try
		# CHECKS
		throw "Illegal arguments" unless arguments.length is 3 and typeof customEvent is 'string' and typeof srcEvent is 'string' and typeof wrapper is 'function'
		throw "Wrapper required 3 arguments" unless wrapper.length is 3
		# Lowercase
		customEvent= customEvent.toLowerCase()
		srcEvent= srcEvent.toLowerCase()
		# checks
		throw "Illegal event name: #{customEvent}" unless EVENT_NAME_REGEX.test(customEvent)
		throw "Illegal event name: #{srcEvent}" unless EVENT_NAME_REGEX.test(srcEvent)
		privateAttr= _componentPrivate.get this
		throw "Unregistred class" unless privateAttr
		# throw "[#{customEvent}] already mapped to [#{srcEv}]" if srcEv= privateAttr.customEvents[customEvent]
		# Add to this class and its subclasses
		subClasses= privateAttr.subClasses
		for cl in subClasses
			privateAttr= _componentPrivate.get cl
			# Check not already defined this custom event
			if srcEv= privateAttr.customEvents[customEvent]
				throw "A subClass already mapped [#{customEvent}] to [#{srcEv}]"
			# Add
			privateAttr.customEvents[customEvent]= srcEvent
			privateAttr.eventWrapper[customEvent]= wrapper
			if arr= privateAttr.linkEvents[srcEvent]
				arr.push customEvent
			else
				privateAttr.linkEvents[srcEvent]= [customEvent]
	catch err
		err= new Error "::createEvent>> #{err}" if typeof err is 'string'
		throw err
	this # chain

###* SET EVENT WRAPPER ###
@setEventWrapper: (eventName, wrapper)->
	privateAttr= _componentPrivate.get this
	throw "Unregistred class" unless privateAttr
	privateAttr.eventWrapper[eventName]= wrapper
	this # chain
