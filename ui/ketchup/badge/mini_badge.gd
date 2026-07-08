@tool
class_name UIKetchupMiniBadge
extends AspectRatioContainer

@export var image: CompressedTexture2D:
	set(val):
		image = val
		_draw_ui()
@export var greyscale: bool:
	set(val):
		greyscale = val
		_draw_ui()
@export var opacity := .5:
	set(val):
		opacity = val
		_draw_ui()


func _draw_ui() -> void:
	if !is_node_ready():
		await ready
	($ColorRect as ColorRect).material.set("shader_parameter/Image", image)
	($ColorRect as ColorRect).material.set("shader_parameter/Greyscale", greyscale)
	($ColorRect as ColorRect).material.set("shader_parameter/Opacity", opacity)


func _ready() -> void:
	_draw_ui()


func _process(_delta: float) -> void:
	var badge_node := $ColorRect as ColorRect

	if badge_node != null:
		badge_node.material.set("shader_parameter/Gloss", get_viewport().get_mouse_position().x / get_viewport().get_visible_rect().size.x)
		badge_node.material.set("shader_parameter/RotaForGloss", get_viewport().get_mouse_position().y / get_viewport().get_visible_rect().size.y)
