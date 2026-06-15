extends Node3D

class_name Animatable

var player: AnimationPlayer


func _ready() -> void:
	player = Helper.add_animation(get_child(0))


func play(ani_name: StringName = &""):
	player.play(ani_name)
	player.advance(0.0)
