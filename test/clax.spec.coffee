Chai = require 'chai'
Sinon = require 'sinon'
sinon_chai = require 'sinon-chai'
do Chai.should
Chai.use sinon_chai

Clax = require '../src/clax.coffee'

describe 'Clax', ->

	class Star
		@shine: ({brightness}) ->
			exploded: brightness > 5
		@error: (message) ->

	class Sun extends Star
		@radius: 695500

	class Moon
		@phase: 'waxing'
		@error: (message) ->
		@authorize: (action, data) =>
			switch action
				when 'glow' then @phase isnt 'new'
				when 'tide' then @phase is 'full'

		@glow: ({color}) ->
			status: "glowing gently with a hint of #{color}"
		@tide: ->
			status: 'tide is coming in!'
		@explore: ({spacecraft}, sender) ->
			status: "#{spacecraft} has landed!"

	describe 'use', ->
		it 'sets a list of constructors as controller hash by lowercasing constructor names', ->
			Clax.use Sun, Moon, Star
			Clax.controllers.should.deep.equal
				sun:  Sun
				moon: Moon
				star: Star

	describe 'parse', ->
		it 'parses a message string and returns an object', ->
			message =
				msg: 'app:action'
				data:
					property: 'value'
			message_string = JSON.stringify message
			parsed_message = Clax.parse message_string
			parsed_message.should.deep.equal
				controller: 'app'
				action: 'action'
				message: message

		it 'throws an exception if JSON parsing fails', ->
			message =
				msg: 'app:action'
				data:
					property: 'value'
			message_string = "#{JSON.stringify message}!!!"
			(-> Clax.parse message_string).should.throw Error, Clax.errors.INVALID_JSON

		it 'parses message objects as well', ->
			message =
				msg: 'app:action'
				data:
					property: 'value'
			parsed_message = Clax.parse message
			parsed_message.should.deep.equal
				controller: 'app'
				action: 'action'
				message: message

		it 'throws an exception if message doesn\'t have a `msg` field', ->
			message =
				data:
					property: 'value'
			(-> Clax.parse message).should.throw Error, Clax.errors.NO_MSG_FIELD

		it 'throws an exception if message\'s `msg` field doesn\'t conform to the `controller-separator-action` format', ->
			message =
				msg: 'action'
				data:
					property: 'value'
			(-> Clax.parse message).should.throw Error, Clax.errors.BAD_MSG_FORMAT

	describe 'validate', ->
		before ->
			Clax.use Star, Sun, Moon

		it 'checks if a parsing result is a valid protocol controller action', ->
			message =
				msg: 'app:action'
				data:
					property: 'value'
			result = Clax.validate Clax.parse message
			result.should.be.an 'object'

		it 'returns an object whose `valid` field should equal true for valid messages and false otherwise', ->
			message =
				msg: 'star:shine'
				brightness: 10
			result = Clax.validate Clax.parse message
			result.should.deep.equal
				valid: yes
				message: message

		it 'fails message validation if specified controller isn\'t registered', ->
			message =
				msg: 'mars:shine'
				brightness: 10
			result = Clax.validate Clax.parse message
			result.should.deep.equal
				valid: no
				error: Clax.errors.CONTROLLER_NOT_FOUND
				message: message

		it 'fails message validation if specified action isn\'t found in registered controllers', ->
			message =
				msg: 'star:burst'
				brightness: 10
			result = Clax.validate Clax.parse message
			result.should.deep.equal
				valid: no
				error: Clax.errors.ACTION_NOT_FOUND
				message: message

		it 'fails message validation if specified controller action isn\'t a method', ->
			message =
				msg: 'sun:radius'
				brightness: 10
			result = Clax.validate Clax.parse message
			result.should.deep.equal
				valid: no
				error: Clax.errors.ACTION_NOT_CALLABLE
				message: message

	describe 'process', ->
		it 'interpretes a message into a protocol action and performes this action if it\'s valid', ->
			message =
				msg: 'sun:shine'
				brightness: 4
			spy = Sinon.spy Sun, 'shine'
			Clax.process message
			do Sun.shine.restore
			spy.should.have.been.calledWith message

		it 'invokes the `error` action if it\'s present on any controller and message is not valid', ->
			message =
				msg: 'sun:burst'
				brightness: 10
			spy = Sinon.spy Star, 'error'
			Clax.process message
			spy.should.have.been.calledWith
				error: Clax.errors.ACTION_NOT_FOUND
				message: message
			do Star.error.restore

		it 'forwards its second argument to action calls', ->
			message =
				msg: 'moon:explore'
				spacecraft: 'Apollo 11'
			sender = 'USA'
			spy = Sinon.spy Moon, 'explore'
			Clax.process message, sender
			do Moon.explore.restore
			spy.should.have.been.calledWith message, sender

	describe 'protect', ->
		error_spy = null
		authorize_spy = null

		beforeEach ->
			error_spy = Sinon.spy Moon, 'error'
			authorize_spy = Sinon.spy Moon, 'authorize'

		afterEach ->
			do Moon.authorize.restore
			do Moon.error.restore

		it 'makes a controller method non-invokable as an action', ->
			Clax.protect Moon, 'authorize', off
			message =
				msg: 'moon:authorize'
				what: 'anything'
			Clax.process message
			error_spy.should.have.been.calledWith
				error: Clax.errors.ACTION_NOT_AUTHORIZED
				message: message

		it 'calls specified authorizing method before invoking an action', ->
			Clax.protect Moon, 'glow', Moon.authorize
			message =
				msg: 'moon:glow'
				color: 'yellow'
			Clax.process message
			authorize_spy.should.have.been.calledWith 'glow', message
			Moon.phase = 'new'
			message =
				msg: 'moon:glow'
				color: 'yellow'
			Clax.process message
			authorize_spy.should.have.been.calledWith 'glow', message
			error_spy.should.have.been.calledWith
				error: Clax.errors.ACTION_NOT_AUTHORIZED
				message: message

		it 'can accept an array of actions to protect', ->
			Clax.protect Moon, ['glow', 'tide'], Moon.authorize
			Moon.phase = 'new'
			message =
				msg: 'moon:glow'
				color: 'yellow'
			Clax.process message
			authorize_spy.should.have.been.calledWith 'glow', message
			error_spy.should.have.been.calledWith
				error: Clax.errors.ACTION_NOT_AUTHORIZED
				message: message
			message =
				msg: 'moon:tide'
			Clax.process message
			authorize_spy.should.have.been.calledWith 'tide', message
			error_spy.should.have.been.calledWith
				error: Clax.errors.ACTION_NOT_AUTHORIZED
				message: message
			Moon.phase = 'full'
			message =
				msg: 'moon:tide'
			Clax.process message
			authorize_spy.should.have.been.calledWith 'tide', message

	describe 'protect_all', ->
		before ->
			Clax.protection = {}

		it 'protects an action or a list of actions for all controllers', ->
			Clax.protect_all ['glow', 'shine'], off
			message =
				msg: 'moon:glow'
				color: 'yellow'
