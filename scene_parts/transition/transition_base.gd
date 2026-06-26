class_name Parts_TransitionBase
extends Control

@export var length := .2
@export var hold := 0.

@export var color := Color("#ff7070"):
	set(nw):
		color = nw
		set_color()

var autoplay := false


func set_color() -> void:
	var rect := $ColorRect as ColorRect
	if rect:
		rect.color = color


func _ready() -> void:
	set_color()
	if autoplay:
		from_dark()


func to_dark() -> Tween:
	($ColorRect as ColorRect).modulate.a = 0.
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property($ColorRect, "modulate:a", 1., length)
	return tween


func from_dark() -> Tween:
	($ColorRect as ColorRect).modulate.a = 1.
	if hold:
		await get_tree().create_timer(hold).timeout
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($ColorRect, "modulate:a", 0., length)
	return tween


func swap_to(new: PackedScene) -> void:
	var new_scene := Node.new()
	var clone: Parts_TransitionBase = self.duplicate()
	clone.autoplay = true
	new_scene.add_child(new.instantiate())
	new_scene.add_child(clone)
	to_dark().finished.connect(
		func() -> void:
			await get_tree().process_frame
			get_tree().change_scene_to_node(new_scene)
	)
