###*
 * Detect form blur and focus to trigger validation
 * To enable components to listen to window events, add class: 'winEvents' to the component
###
# Trigger event to components whit class "winEvents"
_triggerWinEvents= (eventName, event)->
	for element in document.querySelectorAll('.winEvents') when component= element[COMPONENT_SYMB]
		try
			component.emit eventName, event
		catch err
			Component.fatalError 'Uncaught error', err
	ROOT_COMPONENT.emit eventName, event
	return
###* FOCUS ###
_focusListener= (event)->
	element= event.target
	if element is window
		_triggerWinEvents 'window-focus', event
	else
		_closestComponent(element).vFocus event
	return
window.addEventListener 'focus', _focusListener, EVENT_LISTENER_PASSIVE_CAPTURE

###* BLUR EVENT ###
_blurListener= (event)->
	# Exec controls
	element= event.target
	if element is window
		_triggerWinEvents 'window-blur', event
	else if element.form or element.formAction
		_closestComponent(element).vFormControl element
	else
		console.warn '-- Insupported blur event detected!'
	return
window.addEventListener 'blur', _blurListener, EVENT_LISTENER_PASSIVE_CAPTURE

###* FORM RESET ###
_formResetListener= (event)->
	form= event.target
	if form.targName is 'FORM'
		_closestComponent(form).vReset event
	return
window.addEventListener 'reset', _formResetListener, EVENT_LISTENER_PASSIVE_CAPTURE

###* SUBMIT ###
_submitListener= (event)->
	form= event.target
	if form.hasAttribute 'v-submit'
		_closestComponent(form).vSubmit event
	return
window.addEventListener 'submit', _submitListener, {capture: yes, passive: no}


###* Native window event ###
_windowResize= (event)->
	_triggerWinEvents 'window-resize', event
	return
window.addEventListener 'resize', _windowResize, EVENT_LISTENER_PASSIVE_CAPTURE
