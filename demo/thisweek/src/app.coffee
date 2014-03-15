class App

	constructor: ->
		@notes = []
		@active_day = 'Mon'
		@visible_notes = []

	get_week_data: ->
		long_month_names = [
			'January', 'February', 'March', 'April'
			'May', 'June', 'July', 'August'
			'September', 'October', 'November', 'December'
		]
		today = new Date
		last_monday = new Date
		last_monday.setDate today.getDate() - today.getDay() + 1
		last_monday_date = do last_monday.getDate
		long_month: long_month_names[do today.getMonth]
		short_week_names: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
		day: do today.getDate
		week_range: [last_monday_date..last_monday_date + 6]

	create_note: ->
		note =
			header: 'Note'
			article: 'Lorem ipsum'
			day: @active_day
			id: @notes.length
			x: 0
			y: 0
		@notes.push note
		@visible_notes.push note
		note

	update_note: (id, key, value) ->
		@notes[id][key] = value

	move_note: (id, x, y) ->
		@update_note id, x
		@update_note id, y

	switch_day: (day) ->
		@active_day = day
		@visible_notes = @notes.filter (note) => note.day is @active_day

module.exports = App
