http            = require 'http'
{EventEmitter}  = require 'events'
Server          = require('websocket').server

class WebSocketServer extends EventEmitter

	constructor: (@options) ->

	start: ->
		@http_server = http.createServer (request, response) ->
			response.writeHead 404
			do response.end

		@http_server.listen @options.http_port
		@websocket_server = new Server
			httpServer: @http_server

		@websocket_server.on 'request', (request) =>
			connection = request.accept '', request.origin
			@emit 'connection', connection
			connection.on 'message', (message) =>
				@emit 'message', message, connection

exports.WebSocketServer = WebSocketServer
