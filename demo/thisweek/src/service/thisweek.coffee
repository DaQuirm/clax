Clax = require '../../../../src/clax'
{WebSocketController} = require '../../../../src/controllers/websocket-controller.coffee'

class Thisweek extends WebSocketController

	@broadcast: (message, connection) ->
		message.msg = "remote:#{message.action}"
		# message.id  = "#{@connections.indexOf connection}[#{message.id}]"
		delete message.action
		super message, (item) ->
			item isnt connection

module.exports = Thisweek
