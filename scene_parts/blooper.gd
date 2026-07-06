class_name PartsBlooper
extends Node


func play_focus() -> void:
	(%FocusSoundFx as AudioStreamPlayer).pitch_scale = randf_range(0.5, 1.5)
	(%FocusSoundFx as AudioStreamPlayer).play()


func play_click() -> void:
	(%ClickSoundFx as AudioStreamPlayer).pitch_scale = randf_range(0.5, 1.5)
	(%ClickSoundFx as AudioStreamPlayer).play()
