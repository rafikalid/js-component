# Execute Component load: @usedBy Core.init
@__initComponents: (container)->
	_initComponentsOnLoad.forEach (tagName)->
		if clazz= _components.get tagName
			for element in container.getElementsByTagName tagName
				try
					new clazz element
				catch err
					Component.fatalError 'COMPONENT', err
		else
			Component.warn 'COMPONENT', "Unknown component for: <#{tagName}>"
		return
	return
