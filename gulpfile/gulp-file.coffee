###*
 * Gulp file
###
# GridfwGulp= require '../gulp-gridfw'
GridfwGulp= require 'gulp-gridfw'
Gulp= require 'gulp'

compiler= new GridfwGulp Gulp,
	isProd: <%- isProd %>
	delay: 500

# Other compilers
module.exports= compiler
	.js
		name:	'API>> Compile Coffee files'
		src:	'assets/component.coffee'
		dest:	'build/'
		watch:	['assets/component.coffee', 'assets/component/**/*.coffee']
		# data:	params
		# babel:	<%- isProd %>
	###* Copy static files ###
	# .copy
	# 	name:	'API>> Copy static files'
	# 	src:	'assets/lib/**/*'
	# 	dest:	'build/'
