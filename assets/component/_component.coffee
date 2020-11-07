###* Map components ###
_components= new Map()			# mapping all components
_componentPrivate= new Map()	# Map private attributes of each class

#include component/_const.coffee
#include component/_utils.coffee
#include component/_event-wrapper.coffee

###* Main class ###
class Component
	# Constructror
	constructor: (element)->
		super()
		# Set element
		@element= null
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
		previousElement= @element
		if newElement isnt previousElement
			@element= newElement
			newElement[COMPONENT_SYMB]= this
			unless newElement is document
				# newElement.classList.add COMPONENT_CLASS_NAME
				if previousElement and (parent= previousElement.parentNode)
					parent.insertBefore newElement, previousElement
					parent.removeChild previousElement
		this # chain

	###* METHODS ###
	#=include static/_*.coffee
	#=include prototype/_*.coffee
	#=include form/_methods.coffee
	#=include form/_form.coffee
	#=include form/_form-validation.coffee
	#=include form/_files.coffee
	#=include form/_submit.coffee
	#=include basic-actions\_*.coffee

# Alias
Component::html= Component::setElement

# Private attributes
_componentPrivate.set Component,
	tagName:		null
	subClasses:		[Component]	# subclasses
	watch:			{}			# {eventName: [selector, [args], ...]}
	watchSync:		{}			# {eventName: [selector, [args], ...]}
	linkEvents:		{}
	customEvents:	{}

#=include basic-events/_*.coffee

# FORM
#=include form/_native-listeners.coffee

# PRE-ENABLED ACTIONS
Component.enableAction 'click'

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

# TODO: add ROOT_COMPONENT
