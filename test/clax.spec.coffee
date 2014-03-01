Chai = require 'chai'
Sinon = require 'sinon'
sinon_chai = require 'sinon-chai'
do Chai.should
Chai.use sinon_chai

Clax = require '../src/clax.coffee'

describe 'Clax', ->

	class Star
		@shine: ({brightness}) ->
			exploded:(if brightness > 5 then yes else no)
	class Sun extends Star
		radius: 695500
	class Moon

	describe 'use', ->
		it 'sets a list of constructors as controller hash by lowercasing constructor names', ->
			Clax.use Sun, Moon, Star
			Clax.controllers.should.deep.equal
				sun: Sun
				moon: Moon
				star: Star

	describe 'parse', ->
		it 'parses a message string and returns an object', ->
			message =
				msg: 'app:action'
				data:
					property: value
			message_string = JSON.stringify message
			parsed_message = Clax.parse message_string
			parsed_message.should.deep.equal
				controller: 'app'
				action: 'action'
				message: message

		it 'throws an exception if parsing fails', ->
			message =
				msg: 'app:action'
				data:
					property: value
			message_string = "#{JSON.stringify message}!!!"
			(-> Clax.parse message_string).should.throw SyntaxError

	describe 'validate', ->
		before ->
			Clax.use Star, Sun, Moon

		it 'checks if an object is a valid protocol message', ->
			message =
				msg: 'app:action'
				data:
					property: value
			result = Clax.validate message
			result.should.be.an 'object'

		it 'returns an object whose `valid` field should equal true for valid messages and false otherwise', ->
			message =
				msg: 'star:shine'
				brightness: 10
			result = Clax.validate message
			result.should.deep.equal valid: yes

		it 'fails message validation if specified controller isn\'t registered', ->
			message =
				msg: 'mars:shine'
				brightness: 10
			result = Clax.validate message
			result.valid.should.deep.equal
				valid: no
				error: Clax.CONTROLLER_NOT_FOUND
				message: message

		it 'fails message validation if specified action isn\'t found in registered controllers', ->
			message =
				msg: 'star:burst'
				brightness: 10
			result = Clax.validate message
			result.valid.should.deep.equal
				valid: no
				error: Clax.ACTION_NOT_FOUND
				message: message

		it 'fails message validation if specified controller action isn\'t a method', ->
			message =
				msg: 'sun:radius'
				brightness: 10
			result = Clax.validate message
			result.valid.should.deep.equal
				valid: no
				error: Clax.ACTION_NOT_CALLABLE
				message: message

	describe 'process', ->
		it 'interpretes a message into a protocol action and performes this action if it\'s valid', ->
			message =
				msg: 'sun:shine'
				brightness: 4
			spy = Sinon.spy Sun.shine
			response = Clax.process message
			spy.should.have.been.calledWith message
			response.should.deep.equal exploded:no

		it 'returns an error if message isn\'t valid', ->
			message =
				msg: 'sun:burst'
				brightness: 10
			response = Clax.process message
			response.should.deep.equal
				error: Clax.ACTION_NOT_FOUND
				message: message
