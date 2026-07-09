class_name RsDifficultyNumbers
extends Resource

const DROP_TIMEOUT = .5
const WAVE_MAX_OFFSET = 2.
const WAVE_SPEED_TIMER_SPEED = 3.
const WAVE_TIMER_MIN_SPEED = .6

@export var drop_timeout := DROP_TIMEOUT
@export var wave_max_offset := WAVE_MAX_OFFSET
@export var wave_speed_timer_speed := WAVE_SPEED_TIMER_SPEED

var PINEAPPLE_KEY := ScTower_Parts.get_item("ananas").name


func _init(mode: ScTower.Mode) -> void:
	match mode:
		ScTower.Mode.Chicken:
			wave_max_offset = WAVE_MAX_OFFSET / 2.
			wave_speed_timer_speed = WAVE_SPEED_TIMER_SPEED * 2.


func on_successful_stack(part: RsPart = null) -> void:
	# bigger number = easier
	var time_divider := 7.5
	var offset_divider := 75

	wave_speed_timer_speed = (
		wave_speed_timer_speed
		- WAVE_TIMER_MIN_SPEED
		- ((wave_speed_timer_speed - WAVE_TIMER_MIN_SPEED) / time_divider)
		+ WAVE_TIMER_MIN_SPEED
	)
	wave_max_offset += (wave_max_offset / offset_divider)

	if part.name == PINEAPPLE_KEY:
		wave_speed_timer_speed = wave_speed_timer_speed * 1.25
		wave_max_offset = wave_max_offset * .75
