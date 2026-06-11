@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("Dp", "res://addons/godot-debug-panel/dp.tscn")


func _exit_tree() -> void:
	remove_autoload_singleton("Dp")
