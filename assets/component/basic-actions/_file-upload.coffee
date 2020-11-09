###*
 * File-upload
 * @example <div d-click="fileUpload {inputFileName}">
###
fileUpload: (event, args)->
		try
			# Get input
			currentTarget= event.currentTarget
			if inputName= args[1]
				throw "Missing parent form" unless parent= currentTarget.closest 'form'
				throw "Missing input file: #{inputName}" unless (inpFile= parent[inputName]) and inpFile.type is 'file'
			else
				throw 'Missing parent with class="f-cntrl"' unless parent= currentTarget.closest '.f-cntrl'
				throw "Missing input file" unless inpFile= parent.querySelector 'input[type=file]'
			# Get input file
			# reset files
			inpFile.value= ''
			# set on change
			inpFile.addEventListener 'change', @fileUploadChange.bind(this), {once: yes, passive: yes}
			inpFile.click()
		catch err
			@emit 'form-error', err
		return
###* This method is called when files are selected ###
fileUploadChange: (event)->
	try
		input= event.target
		# File list
		if fileLst= input[FILE_LIST_SYMB]
			fileLst.splice 0 unless input.multiple
		else
			fileLst= input[FILE_LIST_SYMB]= []
		# add files
		files= input.files
		len= files.length
		i= 0
		`rt: //`
		while i < len
			file= files[i++]
			# continue if file already selected
			for f in fileLst when (f.name is file.name) and (f.size is file.size) and (f.lastModified is file.lastModified)
				`continue rt`
			# add to queue
			fileLst.push file
		# Create preview
		@filePreview input, fileLst
	catch err
		@emit 'form-error',
			element:	this
			form:		input.form
			error:		err
	return

###*
 * Default File preview
 * @example
 * 		d-preview	# Use default preview and lookup for '.files-preview' container
 * 		d-preview="cssSelector"			# lookup for 'cssSelector' container
 * 		d-preview-bg="cssSelector"		# lookup for 'cssSelector' and change it's background
###
filePreview: (input, files)->
	throw new Error "Please implement ::filePreview"
	# TODO: Implement this in Core-ui
	# if (fxName= input.getAttribute 'd-preview') and (fxName= fxName.trim())
	# 	args= fxName.split(/\s+/)
	# 	fxName= args[0]
	# 	previewFx= @[fxName]
	# 	throw "Missing method: #{fxName}" unless typeof previewFx is 'function'
	# 	previewFx.call this, input, input.files, fileLst, args
	# # Default preview fx
	# else
	# 	@filePreview input, input.files, fileLst, []
	return

###* Reset input file preview ###
filePreviewReset: (input)->
	# TODO: Implement this in core-ui
