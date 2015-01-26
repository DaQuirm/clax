Clax = require '../../../../src/clax'
Thisweek = require './thisweek'
{WebSocketServer} = require './websocket-server'

Clax.use Thisweek

server = new WebSocketServer
	http_port: 8000

server.on 'connection', (connection) ->
	Thisweek.add_connection connection

server.on 'message', (message, connection) ->
	Clax.process message, connection

do server.start


