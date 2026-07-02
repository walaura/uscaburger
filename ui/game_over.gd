class_name UiGameOver
extends Control

@export var speed_mult: float = 1

const STORE_SCENE = preload("res://ui/game_over/store.tscn")
const LINE_ITEM_SCENE = preload("res://ui/game_over/line_item.tscn")

var store_scene: UiGameOver_Store
var did_finish := true

signal on_next_round


func _ready() -> void:
	# for debug
	if get_tree().current_scene == self:
		CurrentRun.inventory.hold_item("ketchup.tres")
		var handler := ScTower_State.new()
		handler._push_line("XX", -69)
		CurrentRun.score.settle(handler)
	if Helper.is_debug:
		speed_mult = .4

	var show_bank_ultimatum := CurrentRun.score.current_session_score < 0.

	if !did_finish:
		var mask_tween := create_tween()
		var end_value := .9 if show_bank_ultimatum else .5
		mask_tween.tween_property(%Mask as ColorRect, "modulate:a", end_value, .5)

	(%NiceOneBg as CanvasItem).material.set("shader_parameter/isGood", did_finish)
	var niceone_player := get_node("%NiceOneAnim") as AnimationPlayer
	niceone_player.play("scroll")

	store_scene = STORE_SCENE.instantiate()
	store_scene.disabled = true
	get_node("%StorePlaceholder").add_child(store_scene)
	store_scene.on_purchase.connect(_on_purchased_item)

	(%BankTkt as Container).visible = show_bank_ultimatum

	_play_intro()
	_DBG_set_up()
	get_tree().paused = true


func _on_next_round() -> void:
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


func _on_purchased_item(item: String, price: int) -> void:
	CurrentRun.inventory.hold_item(item)

	var tween: Tween
	var lines := CurrentRun.score.purchase(price)
	for line in lines:
		tween = (%ScoresTkt as UiGameOver_ScoresTkt).push_ticket_line(line)

	if Helper.is_debug:
		return

	store_scene.disabled = true

	tween.tween_interval(.5)
	tween.finished.connect(func() -> void: _on_next_round())


func _play_intro() -> void:
	var scoretkt_container := get_node("%ScoreTkt") as Container
	var upgradestkt_container := get_node("%UpgradesTkt") as Container

	scoretkt_container.offset_transform_position.x = scoretkt_container.size.x / 2
	scoretkt_container.offset_transform_rotation = -.015
	upgradestkt_container.offset_transform_rotation = .035
	_print_tkt(scoretkt_container, func() -> void: pass).call()

	var print_next := _print_tkt(
		upgradestkt_container,
		func() -> void:
			store_scene.disabled = false
			InputHelper.force_focus.call_deferred(store_scene)
	)
	if (%BankTkt as Container).visible == true:
		var print_upgrades := print_next
		print_next = _print_tkt(%BankTkt as Container, func() -> void: InputHelper.force_focus(store_scene))
		(%BankTktButton as Button).pressed.connect(
			func() -> void:
				(%BankTktButton as Button).disabled = true
				(%BankTktButton as Button).focus_mode = Control.FocusMode.FOCUS_NONE
				print_upgrades.call()
		)

	var tween := (
		(%ScoresTkt as UiGameOver_ScoresTkt)
		. play_intro(
			CurrentRun.score.last_settled_score,
		)
	)

	tween.finished.connect(
		func() -> void:
			print_next.call()
			var ttween := create_tween()
			ttween.tween_property(scoretkt_container, "offset_transform_rotation", -.035, .5 * speed_mult)
			ttween.parallel().tween_property(scoretkt_container, "offset_transform_position:x", 0, .5 * speed_mult)
	)


func _unhandled_input(event: InputEvent) -> void:
	InputHelper.force_grab_focus_on_input(event, self)


func _print_tkt(container: Container, on_done: Callable) -> Callable:
	container.offset_transform_position.y = container.size.y * 1.2

	return func() -> void:
		var tween := create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(container, "offset_transform_position:y", 200, .25 * speed_mult)
		tween.tween_property(container, "offset_transform_position:y", 100, .5 * speed_mult)
		tween.tween_property(container, "offset_transform_position:y", 70, .5 * speed_mult)
		tween.tween_property(container, "offset_transform_position:y", 30, .5 * speed_mult)
		tween.finished.connect(on_done)


func _DBG_set_up() -> void:
	if Cheats == null:
		return
	Cheats.with_container(
		"gameover",
		func(container: Container) -> void:
			var label := Label.new()
			label.text = "if you can read this the store wont auto skip. use this btn"
			label.autowrap_mode = TextServer.AutowrapMode.AUTOWRAP_ARBITRARY
			container.add_child(label)
			var btn1 := Button.new()
			btn1.text = "Next round"
			btn1.pressed.connect(_on_next_round)
			container.add_child(btn1)

			var btn2 := Button.new()
			btn2.text = "Reroll"
			btn2.pressed.connect(_DBG_on_reroll_pressed)
			container.add_child(btn2)

			var btn3 := Button.new()
			btn3.text = "Reroll w/ One million dollars"
			btn3.pressed.connect(
				func() -> void:
					CurrentRun.score._push(1000000)
					_DBG_on_reroll_pressed()
			)
			container.add_child(btn3),
		tree_exiting,
	)


func _DBG_on_reroll_pressed() -> void:
	store_scene.on_reroll()
	pass  # Replace with function body.
