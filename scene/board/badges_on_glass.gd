extends Control

@export_file("*.tscn") var badge_SCpath: String
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
	var front_to_back := (
		precise
		+ Vector2(
			rng.randf_range(-SLOP, SLOP),
			rng.randf_range(-SLOP, SLOP),
		)
	)

	return runway - (Vector2.ONE * BADGE_SIZE) - front_to_back


func _init() -> void:
	CurrentRun.on_run_start.connect(func() -> void: CurrentRun.inventory.item_got_held.connect(_on_item_added))


func _on_item_added(item_name: String) -> void:
	var instance: UiGameOver_StoreProductBadge = ($VisibleOnDev/Control as InstancePlaceholder).create_instance().duplicate()

	var data := CurrentRun.inventory.get_item(item_name)
	if data != null:
		instance.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		instance.icon = data.icon
		instance.edge = randf_range(0, .6)
		instance.custom_minimum_size = Vector2.ONE * BADGE_SIZE
		instance.custom_maximum_size = Vector2.ONE * BADGE_SIZE
		instance.scale = Vector2.ONE * 1.1
		self.add_child(instance)
		instance.position = _position(_len)
		_len += 1


func _on_button_pressed() -> void:
	CurrentRun.inventory.hold_item("ketchup.tres")
	pass  # Replace with function body.
