class Clax

	codes =
		LEFT:  37
		UP:    38
		RIGHT: 39
		DOWN:  40
		SPACE: 32

	@[name] = constant for constant, name of constants

	@use: (controllers...)->
		@controllers = {}
		for controller in controllers
			@controllers[controller.name.toLowerCase()] = controller

	@parse: (message) ->
		# try
		#   @json = JSON.parse message
		# catch ex
		#   throw new Error 'Invalid JSON :('


	@validate: ->

	@process: ->

module.exports = Clax
