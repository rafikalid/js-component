###* lightweight Event emitter for Components ###
on: (eventName, listener)->
	try
		throw 'Expected 2 args' unless arguments.length is 2
		@__on eventName, listener, no
		return this # chain
	catch error
		error= "::on>> #{error}" if typeof error is 'string'
		throw error

once: (eventName, listener)->
	try
		throw 'Expected 2 args' unless arguments.length is 2
		@__on eventName, listener, yes
		return this # chain
	catch error
		error= "::once>> #{error}" if typeof error is 'string'
		throw error

__on: (eventName, listener, isOnce)->
	# Prepare args
	throw new Error "Expected function as listener" unless typeof listener is 'function'
	eventName= eventName.toLowerCase() if typeof eventName is 'string'
	# Create event queue
	unless queue= @__events.get eventName
		queue= []
		@__events.set eventName, queue
	queue.push listener, isOnce

off: (eventName, listener)->
	eventName= eventName.toLowerCase() if typeof eventName is 'string'
	if queue= @__events.get eventName
		switch arguments.length
			when 1
				@__events.delete eventName
			when 2
				i= 0
				len= queue.length
				while i < len
					if queue[i] is listener
						queue.splice i, 2
						len= queue.length
					else
						i+= 2
			else
				throw new Error "::off>> Illegal arguments"
	return this # chain

emit: (eventName, data)->
	throw new Error "::emit>> Illegal arguments" unless arguments.length is 2
	eventName= eventName.toLowerCase() if typeof eventName is 'string'
	if (queue= @__events.get eventName) and (len= queue.length)
		i= 0
		len= queue.length
		while i < len
			try
				# Exec listener
				queue[i].call this, data
				# Check if isOnce
				if queue[i+1]
					queue.splice i, 2
					len= queue.length
				else
					i+= 2
			catch error
				Component.fatalError 'Listener error', error
	else if eventName in ['error', 'form-error']
		Component.fatalError eventName, data
	return this # chain

# Emit event to all components inside the DOM
@emit: (eventName, data)->
	privateAttr= _componentPrivate.get(this)
	for element in document.querySelectorAll privateAttr.tagName
		@getComponent(element).emit eventName, data
	this # chain
