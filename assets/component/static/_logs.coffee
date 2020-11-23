# Used logging sys
@fatalError: (type, message)->
	console.error type, '>>', message
	this # chain
@warn: (type, message)->
	console.warn type, '>>', message
	this # chain
