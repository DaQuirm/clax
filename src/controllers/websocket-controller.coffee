http   = require 'http'
Server = require('websocket').server
Clax   = require '../clax.coffee'

class WebSocketServer

	@connections = {}

	@start = ({http_port}) =>
		@http_server = http.createServer (request, response) ->
			response.writeHead 404
			do response.end

		@http_server.listen http_port
		@websocket_server = new Server
			httpServer: @http_server

		@websocket_server.on 'request', (request) =>
			connection = request.accept '', request.origin
			@connections[connection.remoteAddress] = connection
			connection.on 'message', @process_message, connection

	@process_message = (message, connection) ->
		Clax.process message, connection

exports.WebSocketServer = WebSocketServer

class WebSocketController

	@send = (message, to) ->
		to.sendUTF JSON.stringify message

	@respond = (message, connection) =>
		@send message, connection

	@broadcast = (message, filter = ->yes) =>
		Server.connections
			.filter filter
			.forEach (connection) => @send message, connection

	@error = (message, connection) =>
		@respond message, connection

exports.WebSocketController = WebSocketController
