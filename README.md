# js-component
Lightweight and fast rendering framework

*documentation will be completed soon.*
---

# Hello world
First, Create your component in your javascript file
```javascript
// Create my component and a methods
Component.define('my-component', class MyComponent extends Component{
	constructor(element){
		super(element);
		// My logic
	}
	myMethod(event, args){
		console.log('>> Click: ', args);
	}
});

// Create a global method that doesn't need a parent component
Component.ROOT_COMPONENT.myGlobalMethod= function(event, args){
	console.log('>> Click from my global method', args);
};
```

Then use them in your HTML (or use PUG or any preprocessor of your choice)
```html
<div>
	<my-component>
		<span d-click="myMethod arg1 arg2 ..."> Click here </span>
		<br>
		<span d-click="myGlobalMethod arg1 arg2 ...">Click here for global method</span>
	</my-component>
</div>
```

## Event object
```javascript
event= {
	type:			// Event name
	isSync:			// if this listener is passive or synchronized
	o:				// Original event
	originalEvent:	// Original event
	component:		// Current component object
	currentTarget:	// Current html element that calls the listener
	target:			// html target element (sub components hide its content)
	realTarget:		// Real html element, value of "event.originalEvent.target"
	// Metakies
	metaKey:		Boolean
	altkey:			Boolean
	ctrlKey:		Boolean
	x:				event.originalEvent.x
	y:				event.originalEvent.y
	// Methods
	stopPropagation:	// Stop event propagation to parents
	stopImmediatePropagation:	// Stop propagation to siblings and parents
}
```
If event is synchronized `isSync === true`, your can call `event.originalEvent.stopPropagation()` and `event.originalEvent.stopImmediatePropagation()` to stop propagation in real DOM.

# Basic use:
## Define new Component class
Just call `Component.define` and extend `Component` or its sub-classes
If you use "Core-ui" Component is accessible via `Core.Component`

```javascript
Component.define('component-tag-name', class MyComponentClass extends Component {
	constructor(element){
		super(element);
		// Your constructor logic
	}
	// Add/override your methods
});
```
To prevent confusion with future HTML tags, your tagName should contain at least one "-"

## Get Component class
```javascript
var MyComponentClass= Component.get('component-tag-name');
```

## Get component object
```javascript
// First get your HTML element
var myElement= document.getElementById('myElement');

// And then
var MyComponent= Component.getComponent(myElement);
```

or
```javascript
// use any valid css selector, will select the first element that matches
var MyComponent= Component.getComponent('#myElement');

var MyComponent2= MyComponent.getComponent('#myComp2'); // get a sub component
```

**@throws Error if no class is defined for the target html element**



## Root component
The whole document is a component called `ROOT_COMPONENT`, You can access it via `Component.ROOT_COMPONENT` or `Core.ROOT_COMPONENT` if you use "Core-ui"

# Actions

## Passive actions
you can add actions to any html elements as follow:
```html
<div d-{action-name}="{methodName} {args}"></div>
```

and then enable your actions via JS
```javascript
Component.enableAction('my-event', ...);
Component.enableAction('click', 'mouseover', 'hover', 'move', ...);
// You can enable any valid browser events or create your own

// "click" action is enabled by default.
```

You can call any method on your component object. it has the signature:
```javascript
myMethod(event, args){
	console.log('event>>', event);	// {originalEvent, ...}
	console.log('args>>', args);	// ['myMethod', 'arg1', 'arg2', ...]
}
```

Examples:
```html
<span d-click="myClickMethod myOptionalArgs">Click me</span>
<span d-mouseover="myMouseoverMethod myOptionalArgs">Mouse over here</span>
<span d-hover="myHoverMethod myOptionalArgs">Call mouseover once</span>
<span d-move="myMoveMethod myOptionalArgs">Move</span>
```

## Synchronized actions
If you really need to prevent event default behavior or stop propagation on the real DOM
use synchronized actions as follow:
```javascript
Component.enableSyncAction('my-event', ...);
Component.enableSyncAction('click', 'mouseover', 'hover', 'move', ...);
```
```html
<div d-{action-name}-sync="{methodName} {args}"></div>

<span d-click-sync="myClickMethod myOptionalArgs">Click me</span>
<span d-mouseover-sync="myMouseoverMethod myOptionalArgs">Mouse over here</span>
<!-- ... -->
```
This enables you to call those methods:
```javascript
myMethod(event, args){
	var originalEvent= event.originalEvent;
	originalEvent.preventDefault(); // prevent event default behavior
	originalEvent.stopPropagation(); // stop event propagation in the real DOM
	originalEvent.stopImmediatePropagation(); // stop event Immediate propagation in the real DOM
}
```
**Sync actions as known could reduce your browser performance on events like "mousemove" and "scroll"!**

## Predefined actions
### History action
call `history.back()`
```html
<span d-click="back">Go Back</span>
```

### Form actions
@see "Form section" bellow for form actions.

# Watch events
It's preferable to use "actions" for most cases instead of "watch" for clear code.
You can watch events on your component (or ROOT_COMPONENT) as follow:
```javascript
MyComponentClass.watch('CSS SELECTOR', {
	click: function(event){ /* Your logic */}
	anyNativeEventName: function(event){ /* Your logic */}
	anyCustomEvent: function(event){ /* Your logic */}
});
```

Your can also use synchronized watch if you need to prevent DOM default behavoir or stop propagation in the real DOM
```javascript
MyComponentClass.watchSync('CSS SELECTOR', {
	click: function(event){
		// Sync watch enables to to call those methods
		event.originalEvent.preventDefault();
		event.originalEvent.stopPropagation();
		event.originalEvent.stopImmediatePropagation();
	}
	anyNativeEventName: function(event){ /* Your logic */}
	anyCustomEvent: function(event){ /* Your logic */}
});
```
**Sync actions as known could reduce your browser performance on events like "mousemove" and "scroll"!**

use `Component.watch` and `Component.watchSync` if you need a global watch (without creating a component)

# Custom events

## Create custom event
```javascript
// Create GLOBAL custom event
Component.createEvent('myCustomEvent', 'basicEvent', function wrapper(event, listener, args){ /* logic */});

// Create event for a class and its subclasses
MyComponentClass.createEvent('myCustomEvent', 'basicEvent', function wrapper(event, listener, args){ /* logic */});
```

## Example
Need:
`mouseover` event is called each time the mouse enters an element and propagate to the parents.
For this reason, `mouseover` is called multiple times on the parent element when mouse moves inside.
we need to create a custom event `hover` that is called only once until the mouse pointer leaves the element.
The code is as follow:
```javascript
const _eventHoverFlag= Symbol('hover');
Component.createEvent('hover', 'mouseover', function(event, listener, args){
	var currentTarget= event.currentTarget;
	if(!currentTarget[_eventHoverFlag]){
		currentTarget[_eventHoverFlag]= true;
		// Create a listener to detect when mouse leaves the element
		var outListener= function(evnt){
			// Check this target isnt inside the current element
			target= evnt.target
			while(target){
				if(target === currentTarget) return; // cancel if the pointer still inside the element
			}
			// after this line, the pointer is no more inside the target element
			currentTarget[_eventHoverFlag]= false;
			// Remove the "outListener"
			window.removeEventListener('mouseover', outListener, {capture: true, passive: true});
		};
		// Add listener to detect when the mouse pointer leaves the element
		window.addEventListener('mouseover', outListener, {capture: true, passive: true});
		// Execute event listener: this will be once until the pointer leaves the element
		var component= event.component;
		var wrappedEvent= new Component.EventWrapper('hover', event.originalEvent, component, currentTarget, currentTarget, event.isSync);
		listener.call(component, wrappedEvent, args);
	}
});
```

## Predefined custom events
- hover: called once when the mouse pointer enters until it leaves.
- hout:	called when really the mouse pointer leaves the element.

# FORM

## Predefined form actions
### File upload
```html
<form>
	<!-- use action "uploadFile {inputName}" -->
	<input type="file" name="inputName" class="hidden" />
	<span d-click="uploadFile inputName"> Upload files </span>

	<!-- OR wrap everyting inside ".f-cntrl" and only use "uploadFile" -->
	<div class="f-cntrl">
		<input type="file" name="***" class="hidden" />
		<span d-click="uploadFile"> Upload files </span>
	</div>
</form>
```

#### Optional attributes on the input file:
`multiple`: To enable selecting multiple files
`accept="image/png, image/*"`: To filter files
`capture="user"`: Use mobile front camera
`capture="environment"`: Use mobile back camera

#### Image preview
If you use "Core-ui", see Core-ui documentation
otherwise, start by overriding the method "filePreview" for your component or Global
```javascript
Component.define('my-tag', class extends Component {
	// ...
	filePreview(input, files){
		// <!> For the browser security reasons, the full files list is contained
		// the second argument "files" instead of "input.files"
		// Add your preview logic for each file
	}
	filePreviewReset(input){
		// Add your logic to reset previews when the user reset the whole form
	}

	// Other methods:
	fileUpload(event, args){
		// NO REASON TO OVERRID THIS METHOD!
	}
	fileUploadChange(event){
		// This method is called when the user chooses files
		// DO NOT OVERRIDE THIS METHOD UNLESS YOU KNOW WHAT YOU DO!
	}
});

// To Override a method globally, do it as follow
Component.filePreview= function(input, files){ /* Your logic */ };
Component.filePreviewReset= function(input, files){ /* Your reset logic */ };
```

### Increment an input number value
```html
<!-- Basic use -->
<div class="f-cntrl">
	<input type="number">
	<!-- increment by 1 -->
	<span d-click="inc 1">Inc by 1</span>
	<!-- decrement by 1 -->
	<span d-click="inc -1">Decrement by 1</span>
</div>

<!-- Apply steps -->
<div class="f-cntrl">
	<input type="number" step="0.2">
	<!-- increment by one step 0.2 -->
	<span d-click="inc 1">Inc by one step</span>
	<!-- decrement by two steps: 0.4 -->
	<span d-click="inc 2">Inc by two steps</span>
</div>

<!-- Apply min and max -->
<div class="f-cntrl">
	<input type="number" min="5" max="80">
	<!-- increment until 80 -->
	<span d-click="inc 5">Inc by 5</span>
</div>

<!-- Apply min and max and loop -->
<div class="f-cntrl">
	<input type="number" min="5" max="80" d-loop>
	<!-- increment until 80 and restart at 5 -->
	<span d-click="inc 5">Inc by 5</span>
</div>

<!-- Show decimals: add attribute "v-decimals" to the input -->
<div class="f-cntrl">
	<input type="number" v-decimals="2">
	<span d-click="inc 5">Inc by 5</span>
</div>
```

### Submit a form
```html
<!-- Submit parent form -->
<form>
	<span d-click="submit">Submit</span>
</form>

<!-- Submit form with selector -->
<form id="myForm">
</form>
<span d-click="submit #myForm">Submit</span>
```

## Form validation: custom validation methods
You can call any method on your class prefixed with "v-" when input validation
"async" methods are supported too, so you can call server or do any async operation.

Example:
```javascript
// Class definition
// The method must be prefixed with "v-"
'v-my-validation-method'(value, optionalParam, inputElement){
	// My validation logic
	// Throw false if validation failed
	// Throw 'warn' if validation failed and has warning
	// To add specific message instead of ones already added to DOM, you have access to the input ;)
	return value // <!> return modified or original value
}
```
and then use it for your form controls
```html
<input type="text" v-my-validation-method>
<!-- or add optional arguments -->
<input type="text" v-my-validation-method="my-param">
```

## Form validation: predefined methods
```html
<!-- Set form control as required -->
<!-- For radio buttons: this means one element is selected ;) -->
<input required />
<input v-required />

<!--
	Input number with decimals
	<!> Validation attributes are called as they appears in the HTML code
	YOU SHOULD PUT THIS ATTRIBUTE AFTER ALL OTHER VALIDATION ATTRIBUTES
-->
<input v-decimals="2" />

<!-- Trim form control content, should be the first validation attribute added -->
<input v-trim />

<!-- Apply a regular expression -->
<input pattern="my-regular-expression" />
<input v-regex="my-regular-expression" />

<!-- Stepped input number -->
<input type="number" step="***" />
<input type="number" v-step="***" />

<!-- Input number max value -->
<input type="number" max="***" />
<input type="number" v-max="***" />

<!-- Input number min value -->
<input type="number" min="***" />
<input type="number" v-min="***" />

<!-- Input number value "Less then", "Less then or equals" -->
<input type="number" v-lt="***" />
<input type="number" v-lte="***" />

<!-- Input number value "Greater then", "Greater then or equals" -->
<input type="number" v-gt="***" />
<input type="number" v-gte="***" />

<!-- Input File: files count -->
<input type="file" v-min="***" />
<input type="file" v-gt="***" />
<input type="file" v-gte="***" />
<input type="file" v-max="***" />
<input type="file" v-lt="***" />
<input type="file" v-lte="***" />

<!-- Input File: files min and max total size -->
<input type="file" v-min-bytes="2Kb" />
<input type="file" v-max-bytes="10Mb" />
<!--
	<!> warning when images:
	Prefer to use "v-submit='imageMaxSize {your_max_width_in_pixels}'"
	to resize images before sending them.
	This will reduce the size.

	'v-max-bytes' checks size before "imageMaxSize" is called
	and so it can prevent good images for you!
-->

<!-- Input File: min and max size for each selected file -->
<input type="file" v-each-min-bytes="2Kb" />
<input type="file" v-each-max-bytes="10Mb" />

<!--
	Check if an input value equals to an other input value
	password confirmation is a use case
-->
Password:
<input type="password" name="myPassword" />
Confirm password:
<input type="password" v-equals="myPassword" />

<!-- Check input content type -->
<input v-type="{type1} {type2} ..." />
<input v-type="empty email" /> <!-- Empty or email -->
<input v-type="tel url" /> <!-- Phone number or URL -->
<!--
This methods supports args: empty, email, tel, number, hex, url
-->

```

## Form operations just before submit
This enables you to do operations before just submitting data:
```html
<!-- call a method or async method -->
<input v-submit="myBeforeSubmitMethod" />
<input v-submit="myBeforeSubmitMethod optionalArguments" />
```
```javascript
// Class definition
myBeforeSubmitMethod(input, optionalArguments){
	// Your logic
}
```
### Predefined methods before submitting
Resize images before sending them to the server to reduce upload bandwidth and time
This requires the library "pica": https://github.com/nodeca/image-blob-reduce/blob/master/dist/image-blob-reduce.min.js
Or override it to use your own logic.
```html
<!-- resize any image that exceeds 1000x1000 -->
<input v-submit="imageMaxSize 1000" />
```
## Show effects and messages when a control has an error or success
```html
<!-- Wrap each control in a parent with "f-cntrl" class -->
<div class="f-cntrl">
	<!-- add input with your validation logic -->
	<input v-validation-logic="args">
	<!-- add your Loading effect if the validation could take time -->
	<div class="when-loading">Loading..</div>
	<!-- add your message/anything when success -->
	<div class="when-done">Anything..</div>
	<!-- add your message/anything when failed and warning -->
	<div class="when-warn">Anything..</div>
	<!-- add your message/anything when failed with error -->
	<div class="when-error">Anything..</div>
</div>
```
If you need to hide the input when "loading", add `hide-when-loading` class to it.
The framework will add the following classes to the parent ".f-cntrl" depending on the state:
- loading
- has-done
- has-warn
- has-error
if you don't use "Core-ui", you need to define those classes in your CSS yourself.

To add animation effect for form controls with errors: override the method "animateInputError(inputElement){}". if you use "Core-ui" it's already done.

## Apply form validation and prevent submitting when has errors
Just add the attribute "v-submit" to the form
```html
<form v-submit>
	<!-- content -->
</form>
```

### Do validation and then call a custom method to send data
```html
<form v-submit="myCustomSubmit optionalArguments">
	<!-- content -->
</form>
```
```javascript
// Class definition
async myCustomSubmit(event, args){
	var form= event.currentTarget;
	// This method will be called if form has no validation errors
	// additional validation logic could ne done here, throws error when failed
	// This method should send data to the server or call form.submit()
}
```

### Predefined submit methods
Those methods requires "Core-ui"
```html
<!-- Disable form submitting -->
<form v-submit="off"> <!-- content --> </form>

<!-- Send as URL encoded -->
<form action="..." v-submit="urlencoded"> <!-- content --> </form>

<!-- Send as multipart data (to support file upload) -->
<form action="..." v-submit="multipart"> <!-- content --> </form>

<!-- Send as json -->
<form action="..." v-submit="json"> <!-- content --> </form>

<!-- Send as GET using Core-ui Router, @see Core-ui Router -->
<form action="..." v-submit="GET"> <!-- content --> </form>
```
Those methods expect response as JSON with following information:
```javascript
// If you use "Core-ui"
response= {
	// call Core.alert('message')
	alert: 'message'
	// call Core.alert({text: 'message', state:'success'})
	alert: {text: 'message', state:'success'}
	// call Core.alert({html: '<b>message</b>', state:'danger'})
	alert: {html: '<b>message</b>', state:'danger'}

	// Call Core-ui Router
	goto: 'URI'
	// Old page change (disable Core-ui router)
	redirect: 'URI'

	// EXECUTE METHOD: myComponent.methodName(form, response)
	do: 'methodName'
	// add additional attributes as needed, you have full access
	// to this object as the second argument.
	myOptionalArg1: {}
	myOptionalArgn: {}
};
```
## Set your own logic when form submitted and got response
Override method `onFormResponse(form, result)` with your logic
```javascript
// class definition
onFormResponse(form, result){
	// Get result as JSON
	var response= result.json();
	// Get text content instead
	var response= result.text
}
```

## Uploading effect
By default, predefined submit methods will look for element with class "progress", and then inside it for element with class "track" and changes it's width from 0 to 100%

to set your custom uploading effect, override the method "onFormUpload"
```javascript
// class definition
onFormUpload(form, event){
	percent= Math.floor(event.loaded * 100 / event.total);
	// or:  percent= (event.loaded * 100 / event.total) >> 0
}
```


## Other form control operations:
The framework will add the class `active-input` to any input with focus and the class `has-active` to its container with class "f-cntrl".

To autoselect a control's content when focus: add the attribute `d-select` to it.

## Get form data for AJAX
Because of browser security reasons, you will missing selected files in "<input multiple>" controls.
To get all data call:
```javascript
var form= document.querySelector('#myForm');
var formData= Component.toFormData(form);
```

# Component internal events:

## Internal events on every component of a class type
```javascript
// Listen to internal events
myComponent.on('eventName', function listener(data){ /* Logic */ });

// Call a listener only once and than remove it
myComponent.once('eventName', function listener(data){ /* Logic */ })

// Remove listener
myComponent.off('eventName', listener);

// Remove all listeners of an event
myComponent.off('eventName');

// Trigger event
myComponent.emit('eventName', {data});

// Trigger events every component of a class inside the DOM
// Only components that are in the DOM will receive the event
MyComponentClass.emit('eventName', {data});

// Triger event to specific components
var elements= document.querySelectorAll('YOUR_SELECTOR');
for(var i=0, len= elements.length; i<len; i++){
	Component.getComponent(elements[i]).emit('eventName', {data});
}
```

## Predefined events
**error** : Triggered when a error happens
**form-error** : Triggered when form error

# CONST
`Component.EMAIL_REGEX`:	Email check Regular expression
`Component.TEL_REGEX`:	Tel check Regular expression
`Component.HEX_REGEX`:	Hex check Regular expression

# Utilities

## Convert Bytes expression to bytes
```javascript
var bytes= Component.toBytes(25);		// returns: 25
var bytes= Component.toBytes('5B');		// returns: 5
var bytes= Component.toBytes('6Kb');	// returns: 6 * 2^10
var bytes= Component.toBytes('6Mb');	// returns: 6 * 2^20
var bytes= Component.toBytes('6Gb');	// returns: 6 * 2^30
var bytes= Component.toBytes('6Tb');	// returns: 6 * 2^40
var bytes= Component.toBytes('6Pb');	// returns: 6 * 2^50
var bytes= Component.toBytes('6Eb');	// returns: 6 * 2^60
var bytes= Component.toBytes('6Zb');	// returns: 6 * 2^70
var bytes= Component.toBytes('6Yb');	// returns: 6 * 2^80
var bytes= Component.toBytes(Infinity);	// returns: Infinity
```
