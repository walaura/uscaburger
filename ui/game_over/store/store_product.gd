class_name UiGameOver_StoreProduct
extends Node

const BADGE_SLOP := -2.

@onready var hover_tween: Tween

@export var product: RsUnlockable:
	set(val):
		product = val
		_is_affordable = CurrentRun_Inventory.is_affordable(product)
		if is_node_ready():
			_draw_ui()

var _did_purchase := false:
	set(val):
		_did_purchase = val
		if val == true:
			on_purchase_pressed.emit()

var _is_affordable := false

signal on_purchase_pressed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if product != null:
		_draw_ui()


func _draw_ui() -> void:
	var name_node := get_node("%Name") as RichTextLabel
	name_node.text = ""
	name_node.push_bold()
	name_node.add_text(product.name)
	name_node.pop_all()

	var desc_node := get_node("%Desc") as RichTextLabel
	desc_node.text = product.desc

	var price_node := get_node("%Price") as Label
	price_node.text = Helper.format_currency(product.price)

	var badge_node := get_node("%Badge") as UiGameOver_StoreProductBadge
	var rng := RandomNumberGenerator.new()
	badge_node.position = Vector2(
		rng.randf_range(BADGE_SLOP * -1, BADGE_SLOP),
		rng.randf_range(BADGE_SLOP * -1, BADGE_SLOP),
	)
	badge_node.icon = product.icon
	badge_node.animate()

	($ColorRect as Control).offset_transform_rotation = randf_range(-.2, .2)
	if _is_affordable == false:
		($"HBoxContainer/VBoxContainer" as Control).modulate.a = .5
		($ColorRect as Control).visible = true
	else:
		($"HBoxContainer/VBoxContainer" as Control).modulate.a = 1


func _process(_delta: float) -> void:
	var buy_node := get_node("%Buy") as Button
	buy_node.disabled = !_is_affordable or _did_purchase

	if _did_purchase:
		var check_node := get_node("%TextureRect") as TextureRect
		check_node.texture = load("res://asset/ui/badge-purch-after.png")


func _on_buy_pressed() -> void:
	_did_purchase = true


func _on_buy_mouse_entered() -> void:
	if not _is_affordable:
		return
	hover(false)


func _on_buy_mouse_exited() -> void:
	hover(true)


func hover(is_out: bool) -> void:
	if hover_tween != null:
		hover_tween.kill()
	hover_tween = create_tween()

	var badge_node := get_node("%Badge") as UiGameOver_StoreProductBadge
	var wrapper := get_node("%HBoxContainer") as Container
	wrapper.pivot_offset_ratio = Vector2.ONE / 2

	if is_out:
		hover_tween.tween_property(wrapper, "rotation", 0, .25)
		hover_tween.parallel().tween_property(badge_node, "edge", 0, .25)
		hover_tween.parallel().tween_property(wrapper, "scale", Vector2.ONE, .25)

	else:
		hover_tween = hover_tween.set_loops()
		var start_x := -.05
		var end_x := .05
		hover_tween.tween_property(badge_node, "edge", .5, .25)
		hover_tween.parallel().tween_property(wrapper, "scale", Vector2.ONE * 1.05, .1)
		hover_tween.parallel().tween_property(wrapper, "rotation", end_x, 1)
		hover_tween.tween_property(wrapper, "rotation", start_x, 1).from(end_x)
