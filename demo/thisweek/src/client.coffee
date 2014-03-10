window.Clax = require '../../../src/clax'

window.addEventListener 'load', ->

	week_nav = document.querySelector 'nav > ul'
	week_nav.addEventListener 'click', (event) ->
		(week_nav.querySelector '.selected')?.classList.remove 'selected'
		if event.target.nodeName.toLowerCase() is 'button'
			event.target.parentNode.classList.add 'selected'
