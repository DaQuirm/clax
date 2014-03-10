gulp 	   = require 'gulp'
rename     = require 'gulp-rename'
browserify = require 'gulp-browserify'
stylus     = require 'gulp-stylus'
notify     = require 'gulp-notify'
connect    = require 'gulp-connect'

gulp.task 'connect',
	connect.server
		root: [__dirname]
		port: 1337
		livereload: true
		open:
			browser:'google-chrome'

gulp.task 'coffee', ->
	gulp.src './src/client.coffee', read:false
		.pipe browserify
			transform: ['coffeeify'],
			extensions: ['.coffee']
		.on 'error', ({message}) -> console.log message
		.pipe rename 'client.js'
		.pipe gulp.dest './src'

gulp.task 'stylus', ->
	gulp.src './stylesheets/*.styl'
		.pipe do stylus
		.on 'error', ({message}) -> console.log message
		.pipe gulp.dest './stylesheets'

gulp.task 'watch', ->
	gulp.watch './src/client.coffee', ['coffee']
	gulp.watch './stylesheets/*.styl', ['stylus']
