###* Mouse basic events ###
_eventHoverFlag= Symbol 'hover'
_eventHoutFlag= Symbol 'hout'
Component
# Hover
.createEvent 'hover', 'mouseover', (event, listener, args)->
	currentTarget= event.currentTarget
	unless currentTarget[_eventHoverFlag]
		# set flag to flase when quiting the element
		currentTarget[_eventHoverFlag]= yes
		outListener= (evnt)->
			unless _isParentOf currentTarget, evnt.target
				currentTarget[_eventHoverFlag]= no
				window.removeEventListener 'mouseover', outListener, {capture: true, passive: true}
			return
		window.addEventListener 'mouseover', outListener, {capture: true, passive: true}
		# Execute handler
		component= event.component
		listener.call component, (new EventWrapper 'hover', event.o, component, currentTarget, currentTarget, event.isSync), args
	return
# Hout
.createEvent 'hout', 'mouseover', (event, listener, args)->
	currentTarget= event.currentTarget
	unless currentTarget[_eventHoutFlag] # if not already entred
		currentTarget[_eventHoutFlag]= true
		outListener= (evnt)=>
			unless _isParentOf currentTarget, evnt.target
				currentTarget[_eventHoutFlag]= no
				window.removeEventListener 'mouseover', outListener, {capture: true, passive: true}
				# Exec
				component= event.component
				listener.call component, (new EventWrapper 'hout', event.o, component, currentTarget, currentTarget, no), args
			return
		window.addEventListener 'mouseover', outListener, {capture: true, passive: true}
	return
