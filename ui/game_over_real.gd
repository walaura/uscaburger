class_name UI_GameOverReal
extends Control


func _ready() -> void:
	if get_tree().current_scene == self:
		CurrentRunState.inventory_handler.hold_item("ketchup.tres")
		var handler := Scene_Tower_ScoreHandler.new()
		handler._push_line("XX", -21000)
		CurrentRunState.score_handler.settle(handler)
	get_tree().paused = true

	(%TryAgainButton as Button).modulate.a = .0
	(%TryAgainButton as Button).disabled = true
	print(CurrentRunState.score_handler.last_settled_score)
	var tween := (
		(%ScoresTkt as UI_GameOver_ScoresTkt)
		. play_intro(
			CurrentRunState.score_handler.last_settled_score,
		)
	)

	tween.finished.connect(
		func() -> void:
			var btn_tween := create_tween()
			(%TryAgainButton as Button).disabled = false
			btn_tween.tween_property(%TryAgainButton as Button, "modulate:a", 1., .5)
	)


func _on_try_again_button_pressed() -> void:
	get_tree().paused = false
	await get_tree().process_frame
	get_tree().change_scene_to_packed(preload("uid://e1vyixvrx7xi"))
