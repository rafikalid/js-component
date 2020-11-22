###*
 * Move
 * Movestart
 * Moveends
 * Those events are dispatched on elements, so we can just use theme like native ones
###
do ->
	# Wrapped move event
	class _moveEventWrapper extends EventWrapper
		constructor: (event, moveData)->
			super event.type, event.originalEvent, event.component, event.currentTarget, event.target, event.isSync
			# Values
			@originalX=	_moveData[1]
			@originalY=	_moveData[2]
			@dx=		_moveData[6]
			@dy=		_moveData[7]
			@dt=		_moveData[8]
			return
	# Create native move event
	_moveEvent= (evnt, eventName)->
		new MouseEvent eventName,
			bubbles: on
			cancelable: true
			view: window
			which: 1
			shiftKey: evnt.shiftKey
			altKey: evnt.altKey
			ctrlKey: evnt.ctrlKey
			timeStamp: evnt.timeStamp
			clientX: evnt.clientX
			clientY: evnt.clientY

	# [isFirstMoving, originalX, originalY, lastX, lastY, lastTimeStamp, dx, dy, dt, currentElement]
	_moveData = null
	_moveAddEventListenerOptions= {capture:true, passive: true}
	_eventListenerOptionsOnce= {capture:true, passive: true, once: yes}
	_moveMouseDown= (event)->
		# accept only left button
		return unless event.which is 1
		# mousemove
		mousemove = (evnt)=>
			x = evnt.clientX
			y = evnt.clientY
			tme= evnt.timeStamp
			if _moveData
				_moveData[6] = x - _moveData[3]
				_moveData[7] = y - _moveData[4]
				_moveData[8] = tme - _moveData[5]
			else
				_moveData = [yes, x, y, x, y, tme, 0, 0, 0, event.target]
				return
			# trigger move starts
			if _moveData[0]
				_moveData[0] = no
				event.target.dispatchEvent _moveEvent evnt, 'movestart'
			# trigger move
			event.target.dispatchEvent _moveEvent evnt, 'move'
			# set new values
			_moveData[3] = x
			_moveData[4] = y
			_moveData[5] = tme
			return
		window.addEventListener 'mousemove', mousemove, _moveAddEventListenerOptions
		# mouseup
		mouseUp = (evnt)=>
			window.removeEventListener 'mousemove', mousemove, _moveAddEventListenerOptions
			# trigger move ends
			if _moveData
				unless _moveData[0]
					event.target.dispatchEvent _moveEvent evnt, 'moveend'
				_moveData = null
			return
		window.addEventListener 'mouseup', mouseUp, _eventListenerOptionsOnce
		return
	window.addEventListener 'mousedown', _moveMouseDown, _moveAddEventListenerOptions

	# Add touch support to move event
	_moveTouch= (event)->
		touches= event.changedTouches
		return unless touches.length is 1 # accept only one touch
		# OP
		evnt= touches[0]
		x = evnt.clientX
		y = evnt.clientY
		tme= event.timeStamp
		if _moveData
			_moveData[6] = x - _moveData[3]
			_moveData[7] = y - _moveData[4]
			_moveData[8] = tme - _moveData[5]
		else
			_moveData = [yes, x, y, x, y, tme, 0, 0, 0, event.target]
			return
		# trigger move starts
		if _moveData[0]
			_moveData[0] = no
			event.target.dispatchEvent _moveEvent evnt, 'movestart'
		# trigger move
		event.target.dispatchEvent _moveEvent evnt, 'move'
		# set new values
		_moveData[3] = x
		_moveData[4] = y
		_moveData[5] = tme
		return
	_moveTouchEnd= (event)->
		if _moveData
			unless _moveData[0]
				_moveData[9].dispatchEvent _moveEvent event, 'moveend'
			_moveData = null
		return
	window.addEventListener 'touchmove', _moveTouch, _moveAddEventListenerOptions
	window.addEventListener 'touchend', _moveTouchEnd, _moveAddEventListenerOptions

	_moveListenerCaller= (event, listener, args)->
		customEvent= new _moveEventWrapper event.originalEvent, _moveData
		listener.call event.component, customEvent, args
		return

	# Save wrappers
	Component.setEventWrapper 'move', _moveListenerCaller
	Component.setEventWrapper 'movestart', _moveListenerCaller
	Component.setEventWrapper 'moveend', _moveListenerCaller
	return
