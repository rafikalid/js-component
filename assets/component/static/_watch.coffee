###*
 * Event watchers
 * ::_watch={
 * 		eventName: [cssSelector, handlerName, ...]
 * }
 *
 * @example
 * Component.watch 'cssSelector', { click: function(){}, hover: function(){} }
###
@watch:	(cssSelector, options)-> @_watchEvent cssSelector, options, no
@watchSync: (cssSelector, options)-> @_watchEvent cssSelector, options, yes
@__watchEvent: (cssSelector, options, isSync)->
	try
		# Checks
		throw 'Illegal css-selector' unless typeof cssSelector is 'string'
		throw 'Illegal arguments' unless typeof options is 'object' and options?
		# Add listeners
		values= []
		kies= []
		for k,v of options
			throw "Expected handler as function for: #{eventName}. Selector: #{cssSelector}" unless typeof v is 'function'
			kies.push k
			values.push v
		# Add to each subclass
		privateAttr= _componentPrivate.get this
		for clazz in privateAttr.subClasses
			watchQueue= if isSync then privateAttr.watchSync else privateAttr.watch
			for eventName,i in kies
				(watchQueue[eventName]?= []).push cssSelector, values[i]
		# Enbale events
		@__enableNativeEvent kies, isSync
	catch err
		err= new Error "::watch>> #{err}" if typeof err is 'string'
		throw err
	this # chain
