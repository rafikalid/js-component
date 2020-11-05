###* Map components ###
_components= new Map()			# mapping all components
_componentPrivate= new Map()	# Map private attributes of each class
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
				newElement.classList.add COMPONENT_CLASS_NAME
				if previousElement and (parent= previousElement.parentNode)
					parent.insertBefore newElement, previousElement
					parent.removeChild previousElement
		this # chain


	###* METHODS ###
	#=include static/_*.coffee
	#=include prototype/_*.coffee

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
