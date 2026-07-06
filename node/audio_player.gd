class_name AudioPlayer
extends AudioStreamPlayer


func fade_in(timing := .8, from_position := 0.) -> void:
	volume_db = -80.
	var tween := create_tween()
	tween.tween_property(self, "volume_db", 0.0, timing)
	play(from_position)
