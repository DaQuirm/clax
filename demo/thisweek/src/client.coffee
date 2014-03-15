window.Clax = require '../../../src/clax'
window.App  = require './app'

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
	note_nodes = []

	week_nav = document.querySelector 'nav > ul'
	week_data = do App.get_week_data
	for day, index in week_data.week_range
		day_node = document.createElement 'li'
		if week_data.short_week_names[index] is App.active_day
			day_node.classList.add 'selected'
		day_node.innerHTML = """
			<button class="round-button" data-day="#{week_data.short_week_names[index]}">
				#{day}
			</button>
			<div class="button-label">
				#{week_data.short_week_names[index]}
			</div>"""
		week_nav.appendChild day_node

	week_nav.addEventListener 'click', (event) ->
		(week_nav.querySelector '.selected')?.classList.remove 'selected'
		if event.target.matches 'button'
			nav_item = event.target.closest 'li'
			nav_item.classList.add 'selected'
			App.visible_notes.forEach (note) ->
				note_nodes[note.id].classList.add 'hidden'
			App.switch_day event.target.dataset.day
			App.visible_notes.forEach (note) ->
				note_nodes[note.id].classList.remove 'hidden'

	main = document.querySelector 'main'
	main_rect = do main.getBoundingClientRect
	main.addEventListener 'mousedown', (event) ->
		if event.target.matches '.note'
			drag_target = event.target
			rect = do drag_target.getBoundingClientRect
			delta =
				x: event.clientX - (rect.left - main_rect.left)
				y: event.clientY - (rect.top - main_rect.top)
			move_handler = (event) ->
				do event.preventDefault
				x = event.clientX - delta.x
				y = event.clientY - delta.y
				App.move_note drag_target.dataset.id, x, y
				drag_target.style.webkitTransform = "translate(#{x}px, #{y}px)"
			window.addEventListener 'mousemove', move_handler
			window.addEventListener 'mouseup', (event) ->
				window.removeEventListener 'mousemove', move_handler
				drag_target = null

	main.addEventListener 'input', (event) ->
		node_name = do event.target.nodeName.toLowerCase
		note_id = event.target.closest('.note').dataset.id
		App.update_note note_id, node_name, event.target.textContent

	create_note = document.querySelector '.create-note'
	create_note.addEventListener 'click', ->
		note = do App.create_note
		note_node = document.createElement 'div'
		note_node.classList.add 'note'
		note_node.setAttribute 'data-id', note.id
		note_node.innerHTML = """
			<header contenteditable>#{note.header}</header>
			<time datetime="2014-03-13 19:00">night</time>
			<article contenteditable>#{note.article}</article>"""
		main.appendChild note_node
		note_nodes.push note_node

