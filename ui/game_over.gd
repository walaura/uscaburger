class_name UI_GameOver
extends Control

@export var speed_mult: float = 1

const STORE_SCENE = preload("res://ui/game_over/store.tscn")
const LINE_ITEM_SCENE = preload("res://ui/game_over/line_item.tscn")

var store_scene: UI_GameOver_Store

signal on_next_round


func _ready() -> void:
	# for debug
	if get_tree().current_scene == self:
		CurrentRunState.inventory_handler.hold_item("ketchup.tres")
		CurrentRunState.score_handler.settle(100000)
		speed_mult = .1
	if Helper.is_debug:
		speed_mult = .1

	var niceone_player := get_node("%NiceOneAnim") as AnimationPlayer

	niceone_player.play("scroll")
	store_scene = STORE_SCENE.instantiate()

	get_node("%StorePlaceholder").add_child(store_scene)
	store_scene.on_purchase.connect(
		func(item: String, _price: int) -> void:
			CurrentRunState.inventory_handler.hold_item(item)
			if not Helper.is_debug:
				(%StorePlaceholder as Container).mouse_behavior_recursive = (
					Control.MOUSE_BEHAVIOR_DISABLED
				)
				(%StorePlaceholder as Container).focus_behavior_recursive = (
					Control.FOCUS_BEHAVIOR_DISABLED
				)
				_on_next_round_pressed()
	)

	_play_intro()

	get_tree().paused = true


func _push_ticket_line(
	line: CurrentRunState_ScoreLineItemResource, tween := create_tween()
) -> Tween:
	var scorestkt := get_node("%ScoresTkt") as VBoxContainer
	var tkt_line: UI_GameOver_LineItem = LINE_ITEM_SCENE.instantiate()
	if line is CurrentRunState_ScoreLineItemDividerResource:
		tkt_line.style = (
			tkt_line.Style.EMPTY
			if (line as CurrentRunState_ScoreLineItemDividerResource).is_empty_line
			else tkt_line.Style.LINE
		)
	else:
		tkt_line.deets = line.explanation
	if line.is_total:
		tkt_line.style = tkt_line.Style.HONKING
	tkt_line.scale = Vector2(2, 2)
	tkt_line.anim_length = .5
	tkt_line.modulate = Color.TRANSPARENT
	tkt_line.pivot_offset = Vector2.ONE / 2
	scorestkt.add_child(tkt_line)

	(
		tween
		. tween_property(tkt_line, "scale", Vector2.ONE, .15 * speed_mult)
		. from(
			Vector2.ONE * 1.1,
		)
	)
	tween.parallel().tween_property(tkt_line, "modulate:a", 1, 0.2 * speed_mult)
	if line is not CurrentRunState_ScoreLineItemDividerResource:
		tween.parallel().tween_callback(func() -> void: tkt_line.set_score(line.value))
		tween.tween_property(tkt_line, "modulate:a", 1, .5 * speed_mult)

	return tween


func _play_intro() -> void:
	var scoretkt_container := get_node("%ScoreTkt") as Container
	var upgradestkt_container := get_node("%UpgradesTkt") as Container

	scoretkt_container.offset_transform_position.x = scoretkt_container.size.x / 2
	scoretkt_container.offset_transform_rotation = -.015
	upgradestkt_container.offset_transform_rotation = .035
	_print_tkt(scoretkt_container).call()
	var print_upgrades := _print_tkt(upgradestkt_container)

	var tween := create_tween()
	for line in CurrentRunState.score_handler.last_settled_score:
		_push_ticket_line(line)
	tween.finished.connect(
		func() -> void:
			print_upgrades.call()
			var ttween := create_tween()
			(
				ttween
				. tween_property(
					scoretkt_container,
					"offset_transform_rotation",
					-.035,
					.5 * speed_mult,
				)
			)
			(
				ttween
				. parallel()
				. tween_property(
					scoretkt_container,
					"offset_transform_position:x",
					0,
					.5 * speed_mult,
				)
			)
	)


func _print_tkt(container: Container) -> Callable:
	container.offset_transform_position.y = container.size.y * 1.2

	return func() -> void:
		var tween := create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(container, "offset_transform_position:y", 200, .25 * speed_mult)
		tween.tween_property(container, "offset_transform_position:y", 100, .5 * speed_mult)
		tween.tween_property(container, "offset_transform_position:y", 70, .5 * speed_mult)
		tween.tween_property(container, "offset_transform_position:y", 30, .5 * speed_mult)


func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://board.tscn")


func _on_next_round_pressed() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(%UIContainer as Control, "offset_transform_scale", Vector2.ZERO, .5)
	(
		tween
		. parallel()
		. tween_property(
			%UIContainer as Control,
			"offset_transform_position:y",
			-300.,
			.5,
		)
	)
	tween.finished.connect(
		func() -> void:
			get_tree().paused = false
			on_next_round.emit()
	)


func _on_reroll_pressed() -> void:
	store_scene.on_reroll()
	pass  # Replace with function body.
