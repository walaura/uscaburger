extends Control

@export var score_handler: Run_ScooreHandler


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%NiceOneAnim.play("scroll")
	get_tree().paused = true
	%Score.text = str(score_handler.current_session_score)
	pass  # Replace with function body.


func _on_button_pressed() -> void:
	print(121212)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://board.tscn")
