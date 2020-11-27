###* Create new component ###
@createComponent: (tagName, attributes)->
	throw new Error "Illegal arguments" unless arguments.length in [1,2] and typeof tagName is 'string'
	tagName= tagName.toUpperCase()
	clazz= _components.get tagName
	throw new Error "Unknown Component: #{tagName}" unless clazz
	component= new clazz null, attributes

@createElement: (tagName, attributes)->
	component= @createComponent tagName, attributes
	return component.element
