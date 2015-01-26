class Render
	@init: ->
		@note_nodes = []
		@main = document.querySelector 'main'
		@main_rect = do @main.getBoundingClientRect
		@header_month_name = document.querySelector '.month-name'
		@week_nav = document.querySelector 'nav > ul'
		@create_note_button = document.querySelector '.create-note > button'

	@month_name: (name) ->
		@header_month_name.textContent = name

	@nav: (week_data, active_day) ->
		for day, index in week_data.week_range
			day_node = document.createElement 'li'
			if week_data.short_week_names[index] is active_day
				day_node.classList.add 'selected'
			day_node.innerHTML = """
				<button class="round-button" data-day="#{week_data.short_week_names[index]}">
					#{day}
				</button>
				<div class="button-label">
					#{week_data.short_week_names[index]}
				</div>"""
			@week_nav.appendChild day_node

	@day_number: (week_data) ->
		day_number_node = document.createElement 'div'
		day_number_node.classList.add 'day-number'
		day_number_node.textContent = week_data.day
		@main.appendChild day_number_node

	@switch_day: (day, hidden_notes, visible_notes) ->
		(Render.week_nav.querySelector '.selected')?.classList.remove 'selected'
		nav_item =
			if day instanceof Node
				day
			else
				@week_nav
					.querySelector "[data-day=\"#{day}\"]"
					.closest 'li'
		nav_item.classList.add 'selected'
		hidden_notes.forEach (note) =>
			@note_nodes[note.id].classList.add 'hidden'
		visible_notes.forEach (note) =>
			@note_nodes[note.id].classList.remove 'hidden'

	@create_note: (note) ->
		note_node = document.createElement 'div'
		note_node.classList.add 'note'
		note_node.setAttribute 'data-id', note.id
		note_node.innerHTML = """
			<header contenteditable>#{note.header}</header>
			<time datetime="2014-03-13 19:00">night</time>
			<article contenteditable>#{note.article}</article>"""
		@main.appendChild note_node
		@note_nodes.push note_node

	@move_note: (target, x, y) ->
		target.style.webkitTransform = target.style.transform = "translate(#{x}px, #{y}px)"

	@move_by_id: (id, x, y) ->
		target = @main.querySelector "[data-id=\"#{id}\"]"
		@move_note target, x, y

	@update_note: (id, key, value) ->
		target = @main.querySelector "[data-id=\"#{id}\"] #{key}"
		target.textContent = value

module.exports = Render
