class_name UiGameOver_StoreProduct
extends Node

const BADGE_SLOP := -2.

@onready var hover_tween: Tween
@onready var _BADGE_PATH := (%Badge as InstancePlaceholder).get_instance_path()
@onready var _BADGE_STAMP_PATH := (%BadgeWStamp as InstancePlaceholder).get_instance_path()

@export var product: RsItem:
	set(val):
		product = val
		_is_affordable = CurrentRun.inventory.is_affordable(product)
		if is_node_ready():
			_draw_ui()

var _did_purchase := false:
	set(val):
		_did_purchase = val
		if val == true:
			on_purchase_pressed.emit()

var _is_affordable := false

var disabled := false

var _stamp_node: UiKetchupBadgeWStamp
var _badge_node: UiKetchupBadge

signal on_purchase_pressed


func _init() -> void:
	Helper.preload_scene(_BADGE_PATH)
	Helper.preload_scene(_BADGE_STAMP_PATH)


func _ready() -> void:
	if product != null:
		_draw_ui()


func _draw_ui() -> void:
	var has_seen := SavedRecords.records.has_seen_badge(product)
	var has_purchased := SavedRecords.records.has_purchased_badge(product)
	var name_node := get_node("%Name") as RichTextLabel
	name_node.text = ""
	name_node.push_bold()
	name_node.add_text(product.name)
	name_node.pop_all()

	var desc_node := get_node("%Desc") as RichTextLabel
	desc_node.text = product.desc

	var price_node := get_node("%Price") as Label
	price_node.text = Helper.format_currency(product.price)

	_stamp_node = (await Helper.load_scene(_BADGE_STAMP_PATH)).instantiate()
	_badge_node = (await Helper.load_scene(_BADGE_PATH)).instantiate()
	var rng := RandomNumberGenerator.new()
	_badge_node.position = Vector2(
		rng.randf_range(BADGE_SLOP * -1, BADGE_SLOP),
		rng.randf_range(BADGE_SLOP * -1, BADGE_SLOP),
	)
	_badge_node.icon = product.icon
	_badge_node.tier = product.get_tier_for_display()
	_badge_node.is_new = !has_seen
	_badge_node.is_never_purchased = !has_purchased
	_badge_node.animate_in()

	_stamp_node.badge = _badge_node

	var old_node := %BadgeWStamp
	old_node.replace_by(_stamp_node)
	old_node.queue_free()

	($ColorRect as Control).offset_transform_rotation = randf_range(-.2, .2)
	if _is_affordable == false:
		($"HBoxContainer/VBoxContainer" as Control).modulate.a = .25
		($ColorRect as Control).visible = true
	else:
		($"HBoxContainer/VBoxContainer" as Control).modulate.a = 1


func _process(_delta: float) -> void:
	var buy_node := get_node("%Buy") as Button
	buy_node.disabled = disabled or !_is_affordable or _did_purchase
	buy_node.focus_mode = Control.FOCUS_NONE if buy_node.disabled else Control.FOCUS_ALL

	if _did_purchase:
		var check_node := get_node("%TextureRect") as TextureRect
		check_node.texture = load("res://asset/ui/badge-purch-after.png")


func _on_buy_pressed() -> void:
	_did_purchase = true


func _on_buy_down() -> void:
	($Blooper as PartsBlooper).play_click()


func hover(is_out: bool) -> void:
	if hover_tween != null:
		hover_tween.kill()
	hover_tween = create_tween()

	var wrapper := get_node("%HBoxContainer") as Container
	wrapper.pivot_offset_ratio = Vector2.ONE / 2

	if is_out:
		_stamp_node._on_mouse_exited()
		hover_tween.tween_property(wrapper, "rotation", 0, .25)
		hover_tween.parallel().tween_property(wrapper, "scale", Vector2.ONE, .25)

	else:
		_stamp_node._on_mouse_entered()
		hover_tween = hover_tween.set_loops()
		var start_x := -.05
		var end_x := .05
		hover_tween.parallel().tween_property(wrapper, "scale", Vector2.ONE * 1.05, .1)
		hover_tween.parallel().tween_property(wrapper, "rotation", end_x, 1)
		hover_tween.tween_property(wrapper, "rotation", start_x, 1).from(end_x)


func _on_buy_mouse_entered() -> void:
	(%Buy as Button).grab_focus()


func _on_buy_mouse_exited() -> void:
	(%Buy as Button).release_focus()


func _on_buy_focus_entered() -> void:
	if not _is_affordable:
		return
	hover(false)


func _on_buy_focus_exited() -> void:
	hover(true)
