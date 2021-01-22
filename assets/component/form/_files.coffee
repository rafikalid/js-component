###*
 * Resize images: @useto resize images before uploading
 * @example v-submit="imageMaxSize width"
 * @example v-submit="imageMaxSize 600"
 * @requires https://github.com/nodeca/image-blob-reduce/blob/master/dist/image-blob-reduce.min.js
###
imageMaxSize: (input, args)->
	try
		# This methods uses pica to resize images. Redefine it to use your own logic
		throw new Error "Missing libs: ImageBlobReduce & pica" unless ImageBlobReduce?
		# Max width
		max= +args[1]
		max= 1000 if isNaN max
		resizeArgs= {max: max}
		# Convert to files symb
		unless files= input[FILE_LIST_SYMB]
			files= input[FILE_LIST_SYMB]= Array.from input.files
		if files
			# Resize each file
			reducer= new ImageBlobReduce()
			for file, i in files
				try
					if file.type.startsWith 'image/'
						blob= await reducer.toBlob file, resizeArgs
						# Replace in the list
						newFile= new File [blob], file.name, {type: file.type}
						if newFile.size < file.size
							files[i]= newFile
					else
						Component.warn 'imageMaxSize', "Ignore type: #{file.type}"
				catch error
					Component.fatalError 'imageMaxSize', error
	catch error
		Component.fatalError 'imageMaxSize', error
	return
