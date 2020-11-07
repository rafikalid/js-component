###* @deprecated Before submit files ###
resize: (element, parts)->		@doResizeImages element, 'resize', parts[1], parts[2]
resizeMax: (element, parts)->	@doResizeImages element, 'resizeMax', parts[1], parts[2]

###*
 * Resize images: @useto resize images before uploading
 * @example v-submit="resizeImages {width}x{height} fit"
 * @example v-submit="resizeImages {width}x{height} fit max" # Do not resize if image is small
 * @example v-submit="resizeImages 600x600"
 * @example v-submit="resizeImages x40 contain max"
###
resizeImages: (element, args)->
	# TODO:
