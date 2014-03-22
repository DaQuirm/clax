Clax   = require '../clax.coffee'

class WebSocketController

	@connections = {}

	@add_connection: (connection) ->
		@connections[connection.remoteAddress] = connection

	@send: (message, to) ->
		to.sendUTF JSON.stringify message

	@respond: (message, connection) =>
		@send message, connection

	@broadcast: (message, filter = ->yes) =>
		@connections
			.filter filter
			.forEach (connection) => @send message, connection

	@error: (message, connection) =>
		@respond message, connection

exports.WebSocketController = WebSocketController
