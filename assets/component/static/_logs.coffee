# Used logging sys
fatalError: (type, message)->
	console.log type, '>>', message
	this # chain
