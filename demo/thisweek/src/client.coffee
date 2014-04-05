window.Clax = require '../../../src/clax'
window.App  = require './app'
window.Remote = require './remote'
window.Render = require './render'

Element::matches ?=
	Element::matchesSelector or
	Element::webkitMatchesSelector or
	Element::mozMatchesSelector or
	Element::msMatchesSelector

Element::closest ?= (selector) ->
	if @matches selector
		return @
	else
		element = @
		while element = element.parentNode
			return element if element.matches selector

window.addEventListener 'load', ->
	App = new window.App
	do Render.init
	Remote.link App, Render
	Clax.use Remote
	socket =  new WebSocket 'ws://localhost:8000'
	socket.onmessage = (message) ->
		Clax.process message.data

	week_data = do App.get_week_data
	Render.nav week_data, App.active_day
	Render.month_name week_data.long_month

	Render.week_nav.addEventListener 'click', (event) ->
		if event.target.matches 'button'
			nav_item = event.target.closest 'li'
			day = event.target.dataset.day
			App.switch_day day
			Render.switch_day nav_item, App.hidden_notes, App.visible_notes
			message =
				msg: 'thisweek:broadcast'
				action: 'switch_day'
				day: day
			socket.send JSON.stringify(message)

	Render.day_number week_data

	Render.main.addEventListener 'mousedown', (event) ->
		if event.target.matches '.note'
			drag_target = event.target
			rect = do drag_target.getBoundingClientRect
			delta =
				x: event.clientX - (rect.left - Render.main_rect.left)
				y: event.clientY - (rect.top - Render.main_rect.top)
			move_handler = (event) ->
				do event.preventDefault
				x = event.clientX - delta.x
				y = event.clientY - delta.y
				id = drag_target.dataset.id
				App.move_note id, x, y
				Render.move_note drag_target, x, y
				message =
					msg: 'thisweek:broadcast'
					action: 'move'
					id: id
					x: x
					y: y
				socket.send JSON.stringify(message)
			window.addEventListener 'mousemove', move_handler
			window.addEventListener 'mouseup', (event) ->
				window.removeEventListener 'mousemove', move_handler
				drag_target = null

	Render.main.addEventListener 'input', (event) ->
		node_name = do event.target.nodeName.toLowerCase
		note_id = event.target.closest('.note').dataset.id
		value = event.target.textContent
		App.update_note note_id, node_name, value
		message =
			msg: 'thisweek:broadcast'
			action: 'update'
			id: note_id
			key: node_name
			value: value
		socket.send JSON.stringify(message)

	Render.create_note_button.addEventListener 'click', ->
		note = do App.create_note
		Render.create_note note
		message =
			msg: 'thisweek:broadcast'
			action: 'create'
			id: note.id
			day: note.day
		socket.send JSON.stringify(message)

