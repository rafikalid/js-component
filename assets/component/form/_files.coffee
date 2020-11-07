###*
 * Resize images: @useto resize images before uploading
 * @example v-submit="imageMaxSize width"
 * @example v-submit="imageMaxSize 600"
 * @requires https://github.com/nodeca/image-blob-reduce/blob/master/dist/image-blob-reduce.min.js
###
imageMaxSize: (input, args)->
	# This methods uses pica to resize images. Redefine it to use your own logic
	throw new Error "imageMaxSize>> Missing libs: ImageBlobReduce & pica" unless ImageBlobReduce?
	# Max width
	max= +args[1]
	max= 1000 if isNaN max
	resizeArgs= {max: max}
	# Convert to files symb
	unless files= input[FILE_LIST_SYMB]
		return unless input.files
		files= input[FILE_LIST_SYMB]= Array.from input.files
	# Resize each file
	for file, i in files
		if file.type.startsWith 'image/'
			blob= await ImageBlobReduce.toBlob file, resizeArgs
			# Replace in the list
			files[i]= new File [blob], file.name
		else
			console.warn "imageMaxSize>> Ignore type: #{file.type}"
	return
