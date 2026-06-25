class_name DifficultyNumbersResource
extends Resource

const DROP_TIMEOUT = .5
const WAVE_MAX_OFFSET = 2.
const WAVE_SPEED_TIMER_SPEED = 3.
const WAVE_TIMER_MIN_SPEED = .6

@export var drop_timeout := DROP_TIMEOUT
@export var wave_max_offset := WAVE_MAX_OFFSET
@export var wave_speed_timer_speed := WAVE_SPEED_TIMER_SPEED


func on_successful_stack() -> void:
	# bigger number = easier
	var time_divider := 10
	var offset_divider := 150

	wave_speed_timer_speed = (
			wave_speed_timer_speed - WAVE_TIMER_MIN_SPEED
			- ((wave_speed_timer_speed - WAVE_TIMER_MIN_SPEED) / time_divider)
			+ WAVE_TIMER_MIN_SPEED
	)
	wave_max_offset += (wave_max_offset / offset_divider)
