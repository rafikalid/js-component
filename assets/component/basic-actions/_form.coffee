###*
 * SUBMIT
 * @example
 * d-click="submit"		submit closest form
 * d-click="submit #form" submit selected form
###
submit: (event, args)->
	# Get form
	if form= (if args.length > 1 then @element.querySelector(args.slice(1).join(' ')) else event.currentTarget.closest 'form')
		@vSubmit
			target: form
			preventDefault: ->
	return

###*
 * Input Number arrows
 * @example d-click="inc"
 * @example d-click="inc -1"
###
inc: (event, args)->
	if (cntrl= event.realTarget.closest '.f-cntrl') and (input= cntrl.querySelector('input.active-input') or cntrl.querySelector('input'))
		# INC
		inc= parseFloat args[1]
		inc= 1 if isNaN inc
		step= parseFloat input.step
		step= 1 if isNaN step
		# REAL STEP
		effectiveStep= step * inc
		# MIN VALUE
		min= parseFloat input.min
		min= -Infinity if isNaN min
		# MAX VALUE
		max= parseFloat input.max
		max= Infinity if isNaN max
		# Calc
		value= parseFloat(input.value)
		value= 0 if isNaN value
		value+= effectiveStep
		# Loop
		if input.hasAttribute 'd-loop'
			if value > max
				value= min
			else if value < min
				value= max
		else if value > max
			value= max
		else if value < min
			value= min
		# Decimals
		if (decimals= input.getAttribute('v-decimals')) and (decimals= +decimals) and Number.isSafeInteger(decimals) and decimals > 0
			value= value.toFixed decimals
		# save
		input.value= value
		input.focus()
	return
