Clax = require '../../../../src/clax'
{WebSocketController} = require '../../../../src/controllers/websocket-controller.coffee'

class Thisweek extends WebSocketController

	@broadcast: (message) ->
		super message

module.exports = Thisweek
