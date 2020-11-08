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
## Define new Component
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

**@throws Error if no class is defined for target html element**



## Root component
The whole document is a component called `ROOT_COMPONENT`, You can access it via `Component.ROOT_COMPONENT` or `Core.ROOT_COMPONENT` if you use "core-ui"

# Actions
you can add actions to any html elements as follow:
```html
<div d-{action-name}="{methodName} {args}"></div>
```

and then enable your actions via JS
```javascript
Component.enableAction('my-event');
Component.enableAction('click', 'mouseover', 'hover', 'move');

// "click" action is enabled by default.
```
You can call any method on your component object. it has the signature:
```javascript
myMethod(event, args){
	console.log('event>>', event);	// {originalEvent, ...}
	console.log('args>>', args);	// ['myMethod', 'arg1', 'arg2', ...]
}
```

Example:
```html
<span d-click="myClickMethod myOptionalArgs">Click me</span>
<span d-mouseover="myMouseoverMethod myOptionalArgs">Mouse over here</span>
<span d-hover="myHoverMethod myOptionalArgs">Call mouseover once</span>
<span d-move="myMoveMethod myOptionalArgs">Move</span>
```

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
