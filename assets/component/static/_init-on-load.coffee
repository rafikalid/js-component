# Execute Component load: @usedBy Core.init
@__initComponents: (container)->
	_initComponentsOnLoad.forEach (tagName)->
		if clazz= _components.get tagName
			try
				# Faster but not work on document fragments
				tagElements= container.getElementsByTagName tagName
			catch error
				# If it's a document fragment
				tagElements= container.querySelectorAll tagName
			for element in tagElements
				try
					new clazz element
				catch err
					Component.fatalError 'COMPONENT', err
		else
			Component.warn 'COMPONENT', "Unknown component for: <#{tagName}>"
		return
	return
