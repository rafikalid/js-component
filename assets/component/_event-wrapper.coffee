###* WRAP EVENT ###
class EventWrapper
	constructor: (eventName, event, component, currentTarget, target, isSync)->
		@o= @originalEvent= event
		@type=				eventName
		@component=			component
		@currentTarget=		currentTarget
		@target=			target
		@isSync=			isSync
		@realTarget= event.realTarget or event.target
		@bubbles= @bubblesImmediate= yes
		# Main values
		@metaKey= event.metaKey
		@altKey= event.altKey
		@ctrlKey= event.ctrlKey
		@x= event.x or event.clientX
		@y= event.y or event.clientY
		return
	stopPropagation: ->
		@bubbles= off
		this # chain
	stopImmediatePropagation: ->
		@bubbles= off
		@bubblesImmediate = off
		this # chain
