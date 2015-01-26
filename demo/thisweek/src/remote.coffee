class Remote
	@link: (@app, @render) ->

	@create: ({id, day}) ->
		note = @app.create_note id, day
		@render.create_note note

	@move: ({id, x, y}) ->
		@app.move_note id, x, y
		@render.move_by_id id, x, y

	@update: ({id, key, value}) ->
		@app.update_note id, key, value
		@render.update_note id, key, value

	@switch_day: ({day}) ->
		@app.switch_day day
		@render.switch_day day, @app.hidden_notes, @app.visible_notes

module.exports = Remote
