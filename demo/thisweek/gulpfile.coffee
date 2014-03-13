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
		livereload: yes
		open:
			browser:'google-chrome'

gulp.task 'coffee', ->
	gulp.src './src/client.coffee', read:false
		.pipe browserify
			transform: ['coffeeify'],
			extensions: ['.coffee']
		.on 'error', notify.onError 'Error: <%= error.message %>'
		.pipe rename 'client.js'
		.pipe gulp.dest './src'
		.pipe do connect.reload
		return

gulp.task 'stylus', ->
	gulp.src './stylesheets/thisweek.styl'
		.pipe do stylus
		.on 'error', notify.onError 'Error: <%= error.message %>'
		.pipe gulp.dest './stylesheets'
		.pipe do connect.reload
		return

gulp.task 'watch', ['connect', 'coffee', 'stylus'], ->
	gulp.watch './src/client.coffee', ['coffee']
	gulp.watch './stylesheets/*.styl', ['stylus']
