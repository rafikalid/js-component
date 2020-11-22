<% var Core= false; %>
do->
	'use strict'
	#=include _utils.coffee
	#=include ../../core-event-emitter/assets/event-emitter/_main.coffee
	#=include component/_component.coffee

	# Export interface
	if module? then module.exports= Component
	else if window? then window.Component= Component
	else
		throw new Error "Unsupported environement"
	return
