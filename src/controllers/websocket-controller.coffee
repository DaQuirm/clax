Clax   = require '../clax.coffee'

class WebSocketController

	@connections = []

	@add_connection: (connection) ->
		@connections.push connection

	@send: (message, to) ->
		to.sendUTF JSON.stringify message

	@respond: (message, connection) =>
		@send message, connection

	@broadcast: (message, filter = ->yes) =>
		console.log "Broadcasting #{JSON.stringify message}"
		for connection in @connections when filter connection
			@send message, connection

	@error: (message, connection) =>
		@respond message, connection

exports = WebSocketController
