extends CanvasLayer

var game_time: int = 6 * 60
var day: int = 1
var month: int = 1
var year: int = 1

@onready var clock_label: Label = $ClockLabel

func _ready():
	update_clock()

func _on_time_tick_timeout():
	game_time += 1

	if game_time >= 1440:
		game_time = 0
		day += 1

		if day > 30:
			day = 1
			month += 1

		if month > 12:
			month = 1
			year += 1

	update_clock()

func update_clock():
	var hours: int = game_time / 60
	var minutes: int = game_time % 60
	var time_str := "%02d:%02d" % [hours, minutes]
	clock_label.text = "Day %d  %s" % [day, time_str]
