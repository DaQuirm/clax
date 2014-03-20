class Clax

	constants =
		MSG_SEPARATOR: ':'

	@[name] = constant for name, constant of constants

	@errors =
		ACTION_NOT_AUTHORIZED: 'Action is not authorized'
		ACTION_NOT_CALLABLE:   'Action is not a method of the controller'
		ACTION_NOT_FOUND:      'Action is not found'
		BAD_MSG_FORMAT:        'Bad `msg` field format'
		CONTROLLER_NOT_FOUND:  'Controller is not found'
		INVALID_JSON:          'Invalid JSON'
		NO_MSG_FIELD:          'Message has no `msg` field'

	@protected: {}

	@use: (controllers...)->
		@controllers = {}
		for controller in controllers
			@controllers[controller.name.toLowerCase()] = controller

	@parse: (message) ->
		json = null
		switch typeof message
			when 'string'
				try
					json = JSON.parse message
				catch ex
					throw new Error Clax.errors.INVALID_JSON
			when 'object'
				json = message

		throw new Error Clax.errors.NO_MSG_FIELD unless 'msg' of json
		[controller, action] = json.msg.split Clax.MSG_SEPARATOR
		throw new Error Clax.errors.BAD_MSG_FORMAT if not controller? or not action?

		controller: controller
		action:     action
		message:    json

	@validate: ({controller, action, message}) ->
		result = message:message
		error =
			unless controller of @controllers
				Clax.errors.CONTROLLER_NOT_FOUND
			else unless action of @controllers[controller]
				Clax.errors.ACTION_NOT_FOUND
			else unless typeof @controllers[controller][action] is 'function'
				Clax.errors.ACTION_NOT_CALLABLE
		result.error = error if error?
		result.valid = not result.error?
		result

	@process: (message, args...) ->
		message = @parse message
		{valid, error} = @validate message
		{controller, action, message} = message
		if valid
			protection = @protected[controller]?[action]
			authorized =
				if protection?
					if typeof protection is 'function'
						protection action, message
					else if typeof protection is 'boolean'
						protection
				else yes
			if authorized
				@controllers[controller][action] message, args...
			else
				error: Clax.errors.ACTION_NOT_AUTHORIZED
				message: message
		else
			error: error
			message: message

	@protect: (controller, what, protection) ->
		controller_name = controller.name.toLowerCase()
		what = [what] unless Array.isArray what
		for action in what
			@protected[controller_name] ?= {}
			@protected[controller_name][action] = protection

module.exports = Clax
