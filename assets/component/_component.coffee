###* Map components ###
_components= new Map()			# mapping all components
_componentPrivate= new Map()	# Map private attributes of each class
_initComponentsOnLoad= new Set()	# store tags of components to init
ROOT_COMPONENT= null			# Store ROOT_COMPONENT

#=include _const.coffee
#=include _utils.coffee
#=include _event-wrapper.coffee

###* Main class ###
class Component extends EventEmitter
	# Constructror
	constructor: (element)->
		super()
		# Element
		unless element
			element= document.createElement _components.get(this).tagName
		# Set element
		@__element= null
		@__domElement= null # Real element in the DOM, used because we manipulate dom when new frame
		@__domRaf= null # requestAnimationFrame
		# Store events
		@__events= new Map()
		# Enable element
		@setElement element
		return

	###* Replace HTMLElement with new one ###
	setElement: (newElement)->
		# Convert HTML to html element
		if typeof newElement is 'string'
			DIV_RENDER.html= newElement
			throw new Error "Component::setElement>> The html must contain exactly one element!" if DIV_RENDER.childElementCount isnt 1
			element= DIV_RENDER.firstElementChild
		# Set new Element
		if newElement isnt @__element
			@__element= newElement
			newElement[COMPONENT_SYMB]= this
			unless newElement is document
				# newElement.classList.add COMPONENT_CLASS_NAME
				previousElement= @__domElement
				if previousElement and (parent= previousElement.parentNode)
					cancelAnimationFrame @__domRaf if @__domRaf
					@__domRaf= requestAnimationFrame (t)->
						@__domElement= newElement
						parent.insertBefore newElement, previousElement
						parent.removeChild previousElement
						return
		this # chain

	```
	get element(){ return this.__element }
	```

	###* METHODS ###
	#=include static/_*.coffee
	#=include prototype/_*.coffee
	#=include form/_methods.coffee
	#=include form/_form.coffee
	#=include form/_form-validation.coffee
	#=include form/_files.coffee
	#=include form/_submit.coffee
	#=include basic-actions\_*.coffee

	###* CORE-UI ADDITIONAL ELEMENTS ###
	<% if(Core){ %>
	#=include ../../../core-ui/assets/js/components/actions/_*.coffee
	<% } %>

# Alias
Component::html= Component::setElement

# Private attributes
_componentPrivate.set Component,
	tagName:		null
	subClasses:		[Component]	# subclasses
	watch:			{}			# {eventName: [selector, [args], ...]}
	watchSync:		{}			# {eventName: [selector, [args], ...]}
	linkEvents:		{}			# {eventName: [customEvent1, ....]}
	customEvents:	{}			# {customEvent: parentEvent}
	eventWrapper:	{}			# {eventName: wrapper}

#=include basic-events/_*.coffee

# FORM
#=include form/_native-listeners.coffee

# PRE-ENABLED ACTIONS
Component.enableAction 'click', 'focus'

# Interface
Component.EventWrapper= EventWrapper
Component.COMPONENT_SYMB=	COMPONENT_SYMB
Component.FILE_LIST_SYMB=	FILE_LIST_SYMB
Component.INPUT_VALIDATED=	INPUT_VALIDATED

Component.EMAIL_REGEX=		EMAIL_REGEX
Component.TEL_REGEX=		TEL_REGEX
Component.HEX_REGEX=		HEX_REGEX

# Convert string expression to bytes
Component.toBytes= _toBytes

# ROOT COMPONENT
ROOT_COMPONENT= new Component document
Component.ROOT_COMPONENT= ROOT_COMPONENT
