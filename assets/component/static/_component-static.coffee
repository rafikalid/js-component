###*
 * STATIC METHODS
###

###* @return component class ###
@get: (componentName)->
	clazz= _components.get componentName
	throw new Error "Unknown component: #{componentName}" unless clazz
	return clazz

###* @return component ###
@getComponent: (element)->
	element= @element.querySelector element if typeof element is 'string'
	# get component
	unless component= element[COMPONENT_SYMB]
		if clazz= _components.get element.tagName
			component= new clazz element
		else
			throw new Error "Unknown component: #{element.tagName}"
	return component

###* Define new component ###
@define: do ->
	# Copy private attributes
	_copyPrivate= (obj)->
		result= {}
		for k of obj
			result[k]= obj[k].slice(0)
		return result
	# Main interface
	return (tagName, clazz)->
		try
			throw "Illegal arguments" unless arguments.length is 2 and typeof tagName is 'string' and typeof clazz is 'function'
			throw "Please extend [Component] class instead of use it itself" if clazz is Component
			throw "The class must extend 'Component' or its subclasses" unless clazz.prototype instanceof Component
			throw "name is null!" unless tagName
			throw "Illegal name!" unless COMPONENT_NAME_REGEX.test tagName
			tagName= tagName.toUpperCase()
			throw "Already defined: #{tagName}" if _components.has tagName
			throw "This class already set to tag: <#{privateAttr.tagName}>" if privateAttr= _componentPrivate.get clazz
			# Add class
			_components.set tagName, clazz
			# Private attribues
			parentAttr= _componentPrivate.get clazz.__proto__
			throw "The parent class needs to be added using [::define] method too" unless parentAttr
			privateAttr=
				tagName:		tagName
				subClasses:		[clazz]	# subclasses
				watch:			_copyPrivate(parentAttr.watch)		# {eventName: [selector, [args], ...]}
				watchSync:		_copyPrivate(parentAttr.watchSync)	# {eventName: [selector, [args], ...]}
				linkEvents:		_copyPrivate(parentAttr.linkEvents)	# {nativeEvent: ['customEvent', wrapper, ...]}
				customEvents:	_assign {}, parentAttr.customEvents	# {hover: 'mouseover'}
			_componentPrivate.set clazz, privateAttr
			# Add to supper classes
			prevArr= []
			until cl is Component
				cl= cl.__proto__
				_componentPrivate.get(cl).subClasses.push clazz
		catch err
			err= new Error "DEFINE COMPONENT>> #{err}" if typeof err is 'string'
			throw err
		this # chain
