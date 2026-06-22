extends Control

const BADGE_SIZE := 180
const PADDING := 40

const SLOP = 30

var _len := 0


func _position(index: int) -> Vector2:
	var runway := self.size - Vector2.ONE * (PADDING * 2)
	var max_cols: int = floor(runway.x / BADGE_SIZE)

	var col: int = index % max_cols
	@warning_ignore("integer_division")
	var row: int = floor(index / max_cols)

	var precise := Vector2(PADDING + (col * BADGE_SIZE), PADDING + (row * BADGE_SIZE))
	var rng := RandomNumberGenerator.new()
	var front_to_back := precise + Vector2(
		rng.randf_range(-SLOP, SLOP),
		rng.randf_range(-SLOP, SLOP),
	)

	return runway - (Vector2.ONE * BADGE_SIZE) - front_to_back


# Called when the node enters the scene tree for the first time.
func _init() -> void:
	CurrentRunState.on_run_start.connect(
		func() -> void:
			CurrentRunState.inventory_handler.item_got_held.connect(_on_item_added)
	)


func _on_item_added(item_name: String) -> void:
	var instance: UI_GameOver_StoreProductBadge = (load("res://ui/game_over/store/store_product_badge.tscn") as PackedScene).instantiate()
	var data := load("res://data/unlockables/" + item_name) as UnlockableResource
	if data != null:
		instance.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		instance.icon = data.icon
		instance.custom_minimum_size = Vector2.ONE * BADGE_SIZE
		instance.custom_maximum_size = Vector2.ONE * BADGE_SIZE
		instance.scale = Vector2.ONE * 1.1
		self.add_child(instance)
		instance.position = _position(_len)
		_len += 1


func _on_button_pressed() -> void:
	CurrentRunState.inventory_handler.hold_item("ketchup.tres")
	pass # Replace with function body.
