###* Convert HTMLForm to FormData ###
toFormData: (form)->
	data= new FormData()
	for input in form.elements
		continue if input.disabled or not(inputName= input.name)
		# Input components
		if c= input[INPUT_COMPONENT_SYMB]
			values= c.value
			if _isArray values
				data.append inputName, v for v in values
			else
				data.append inputName, values
		# normal input file
		else if input.type is 'file'
			values= input[FILE_LIST_SYMB] or input.files
			for file in values
				data.append inputName, file, file.name
		# Checkbox & radio
		else if input.type in ['radio', 'checkbox']
			data.append inputName, input.value if input.checked
		else
			data.append inputName, input.value
	return data
# toFormData: (form)->
# 	data= new FormData form
# 	# check for input files
# 	for input in form.querySelectorAll 'input[type="file"]'
# 		inputName= input.name
# 		if files= input[FILE_LIST_SYMB]
# 			data.delete inputName
# 			for file in files
# 				data.append inputName, file, file.name
# 		# remove empty files
# 		else unless input.files.length
# 			data.delete inputName
# 	return data
toFormJSON:	(form)-> JSON.stringify @toFormObj form
toFormObj:	(form)->
	data= {}
	excludeNamesRegex= /^__.+__$/
	for input in form.elements
		continue if input.disabled or not (inputName= input.name) or excludeNamesRegex.test inputName
		# Input components
		if c= input[INPUT_COMPONENT_SYMB]
			data[inputName]= c.value
		# normal input file
		else if input.type is 'file'
			data[inputName]= input[FILE_LIST_SYMB] or input.files
		# Checkbox & radio
		else if input.type in ['radio', 'checkbox']
			data[inputName]= input.value if input.checked
		else
			data[inputName]= input.value
	return data
toFormUrlEncoded: (form)->
	data= new URLSearchParams()
	for input in form.elements
		continue if input.disabled or not(inputName= input.name)
		# Input components
		if c= input[INPUT_COMPONENT_SYMB]
			values= c.value
			if _isArray values
				data.append inputName, v for v in values
			else
				data.append inputName, values
		# normal input file
		else if input.type is 'file'
			values= input[FILE_LIST_SYMB] or input.files
			for file in values
				data.append inputName, file, file.name
		# Checkbox & radio
		else if input.type in ['radio', 'checkbox']
			data.append inputName, input.value if input.checked
		else
			data.append inputName, input.value
	return data.toString()
