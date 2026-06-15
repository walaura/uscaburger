extends Node2D


func _init() -> void:
	visible = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("DBG-Splort"):
		visible = not visible
