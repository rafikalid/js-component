# Is parent of
_isParentOf= (parent, child)->
	while child
		return yes if child is parent
		child= child.parentNode
	return no

_closestComponent= (element)->
	return ROOT_COMPONENT if element in [document, window]
	# Check for closest component
	while element
		if clazz= _components[element.tagName]
			return element[COMPONENT_SYMB] or new clazz element
		element= element.parentNode
	return ROOT_COMPONENT

# Convert string to bytes
_toBytes= do ->
	units=
		'':	1
		b:	1		# Byte
		k:	2**10	# kiloByte
		m:	2**20	# megaByte
		g:	2**30	# gigaByte
		t:	2**40	# teraByte
		p:	2**50	# petaByte
		e:	2**60	# exaByte
		z:	2**70	# zettaByte
		y:	2**80	# yottaByte
	parseRegex= /^\s*(\d+)\s*([a-z])?b?\s*$/i
	# Interface
	return (value)->
		if typeof value is 'string'
			value= value.toLowerCase()
			if value is 'infinity'
				value= Infinity
			else if value= parseRegex.exec value
				mult= units[value[2].toLowerCase()]
				if mult?
					value= parseFloat(value[1]) * mult
				else
					value= null
		else unless typeof value is 'number'
			value= null
		return value
