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

	class Sun extends Star
		@radius: 695500

	class Moon

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
			response = Clax.process message
			do Sun.shine.restore
			spy.should.have.been.calledWith message
			response.should.deep.equal exploded:no


		it 'returns an error if message isn\'t valid', ->
			message =
				msg: 'sun:burst'
				brightness: 10
			response = Clax.process message
			response.should.deep.equal
				error: Clax.errors.ACTION_NOT_FOUND
				message: message
