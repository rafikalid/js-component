###* Convert HTMLForm to FormData ###
toFormData: (form)->
	data= new FormData form
	# check for input files
	for input in form.querySelectorAll 'input[type="file"]'
		inputName= input.name
		if files= input[FILE_LIST_SYMB]
			data.delete inputName
			for file in files
				data.append inputName, file, file.name
		# remove empty files
		else unless input.files.length
			data.delete inputName
	return data
