###* Form validators ###
'v-required': (value, step, input)->
	switch input.type
		when 'checkbox'
			throw false unless input.checked
		when 'radio'
			if (not input.checked) and radioGroup= input.form[input.name]
				isChecked= no
				for el in radioGroup when el.checked
					isChecked= yes
					break
				throw false unless isChecked
		else
			throw false unless value
	return value
'v-step': (value, step, input)->
	return value

'v-decimals': (value, decimals, input)->
	# Fix input number decimals
	if (decimals= +decimals) and Number.isSafeInteger(decimals) and decimals > 0
		value= +value
		throw no if isNaN value
		value= value.toFixed decimals
	return value

###* TRIM ###
'v-trim': (value)-> value.trim()

###* REGEX ###
'v-regex': (value, regex, element)->
	throw false unless (new RegExp regex).test value
	return value

###* NUMBERS COMPARE, FILES COUNT ###
<% function _validatorCompare(expr){ %>(value, param, element)->
	vl= +param
	throw "Illegal param: #{param}" if isNaN(vl)
	if element.type is 'file'
		result= (element[FILE_LIST_SYMB] or element.files)?.length
		throw no if <%-expr %>
	else
		result= +value
		throw no if isNaN(result) or <%-expr %>
	return value
<% } %>
'v-max':	<% _validatorCompare('result > vl') %>
'v-lte':	<% _validatorCompare('result > vl') %>
'v-lt':		<% _validatorCompare('result >= vl') %>

'v-min':	<% _validatorCompare('result < vl') %>
'v-gte':	<% _validatorCompare('result < vl') %>
'v-gt':		<% _validatorCompare('result <= vl') %>

###* FILE MAX SIZE ###
<% function _validatorBytes(expr){ %>(value, param, element)->
	# Prepare param
	bytes= _toBytes param
	throw new Error "Illegal param: #{param}" unless bytes?
	# Check
	if (element.type is 'file') and (files= element[FILE_LIST_SYMB] or element.files)
		total= 0
		total+= f.size for f in files
		throw false if <%- expr %>
	return value
<% } %>
'v-max-bytes': <% _validatorBytes('total >= bytes') %>
'v-min-bytes': <% _validatorBytes('total <= bytes') %>


###* EACH FILE MAX/MIN BYTES ###
<% function _validatorEachBytes(expr){ %>(value, param, element)->
	# Prepare param
	bytes= _toBytes param
	throw new Error "Illegal param: #{param}" unless bytes?
	# Check
	if (element.type is 'file') and (files= element[FILE_LIST_SYMB] or element.files)
		throw false for f in files when <%- expr %>
	return value
<% } %>
'v-each-max-bytes': <% _validatorEachBytes('f.size >= bytes') %>
'v-each-min-bytes': <% _validatorEachBytes('f.size <= bytes') %>

# Check input equals to value of an other input: @example: check password confirmation
'v-equals': (value, param, element)->
	param= param.trim()
	throw no unless value is input.form[param].value
	return value

# Check input type if equals to one of the following
'v-type': (value, param, element)->
	for type in param.trim().toLowerCase().split /[\s,]+/
		try
			switch type
				when 'empty'
					res= !value
				when 'email'
					res= EMAIL_REGEX.test data
				when 'tel'
					res= TEL_REGEX.test data
				when 'number'
					res= data and not isNaN(+data)
				when 'hex'
					res= HEX_REGEX.test data
				when 'url'
					new URL data
					res= yes
			return value if res
		catch error
			res= no
	throw no

# Ignore executing attribute "v-submit". @see vSubmit
# This attribute is to be executed before submiting data
'v-submit': (value, param, element)-> value
