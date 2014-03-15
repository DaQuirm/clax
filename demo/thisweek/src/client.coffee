window.Clax = require '../../../src/clax'

Element::matches ?=
	Element::matchesSelector or
	Element::webkitMatchesSelector or
	Element::mozMatchesSelector or
	Element::msMatchesSelector

closest = (element, selector) ->
	if element.matches selector
		return element
	else
		while element = element.parentNode
			return element if element.matches selector

window.addEventListener 'load', ->

	week_nav = document.querySelector 'nav > ul'
	week_nav.addEventListener 'click', (event) ->
		(week_nav.querySelector '.selected')?.classList.remove 'selected'
		if event.target.nodeName.toLowerCase() is 'button'
			event.target.parentNode.classList.add 'selected'


	main = document.querySelector 'main'
	delegate main, 'mousedown', '.note'

	main.addEventListener 'mousedown', (event) ->
		if event.target.classList.contains 'note'

		else if event.target.parentNode.classList.contains 'note'
			drag_target = event.target
			rect = do drag_target.getBoundingClientRect
			delta =
				x: event.clientX - rect.left
				y: event.clientY - rect.top
			move_handler = (event) ->
				do event.preventDefault
				drag_target.style.webkitTransform = "translate(#{event.clientX - delta.x}px, #{event.clientY - delta.y}px)"
			window.addEventListener 'mousemove', move_handler
			window.addEventListener 'mouseup', (event) ->
				window.removeEventListener 'mousemove', move_handler
				drag_target = null

	main.addEventListener 'dblclick', (event) ->
		if event.target.parentNode.classList.contains 'note'
			event.target.contenteditable = true

