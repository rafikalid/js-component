###*
 * Predefined submit methods
###
urlencoded:	(event, parts)-> @__sendFormData 'urlencoded', event, parts
multipart:	(event, parts)-> @__sendFormData 'multipart', event, parts
json:		(event, parts)-> @__sendFormData 'json', event, parts
off:		(event, parts)-> # Disable submit
GET:		(event, parts)->
	throw new Error "Core-ui is required" unless Core?.defaultRouter?
	form= event.target
	url= new URL form.action, document.location.href
	url.search= @toFormUrlEncoded form
	# params= url.searchParams
	#
	# (new FormData form).forEach (v,k)->
	# 	params.append k, v if typeof v is 'string'
	# 	return
	Core.defaultRouter.goto url
	return

# Loading effect
onFormUpload: (form, event)->
	if event.lengthComputable and ($progress= form.querySelector '.progress')
		requestAnimationFrame ->
			$progress.classList.remove 'loading'
			prcent= (event.loaded * 100 / event.total)>>0
			$progress.querySelector('.track')?.style.width= "#{prcent}%"
			$progress.querySelector('.label')?.innerText "#{prcent}%"
			return
	return
# When receiving response from server after sending form
onFormResponse: (form, result)->
	try
		result= result.json() # convert to JSON
	catch err
		result= {error: err}
	if typeof result is 'string'
		result= error: result
	# Show simple message: result.message= 'Simple message'
	# Show message with state: result.message= {text: 'Simple message', state: 'danger'}
	# Show message with HTML: result.message= {html: '<b>Simple</b>', state:'warn'}
	await Core.alert arg if arg= result.alert
	if arg= result.error
		arg= arg.message unless typeof arg is 'string'
		await Core.alert {text: arg, state: 'danger'}

	# Execute method
	if (arg= result.do) and (fx= @[arg]) and typeof fx is 'function'
		await fx.call this, form, result
	# redirect
	else if arg= result.goto
		return Core.goto arg
	else if(arg= result.replace) and (r= Core.defaultRouter)
		return r.replace arg
	else if arg= result.redirect
		return Core.goOut arg
	return
# Send data using ajax
__sendFormData: (type, event, parts)->
	ajaxApi= Core.ajax
	form= event.target
	# Create form data
	if type is 'json'
		formData= @toFormJSON form
	else
		formData= @toFormData form
	# Send ajax
	result= await ajaxApi.post
		data:	formData
		url:	form.action
		type:	type
		upload: @onFormUpload.bind this, form
	await @onFormResponse form, result
	return
