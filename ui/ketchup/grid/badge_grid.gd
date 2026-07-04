class_name UiKetchupBadgeGrid
extends GridContainer

var _pop_tween: Tween

@export var animate_on_ready := true
@export var badges: Array[UiKetchupBadgeGridIcon]


func _ready() -> void:
	_pop_tween = create_tween()
	#if animate_on_ready == false:
	#_pop_tween.pause()

	if get_child_count() == 0:
		for badge in badges:
			if badge.badge is UiKetchupBadge:
				(badge.badge as UiKetchupBadge).animates = false
				_pop_tween.tween_callback((badge.badge as UiKetchupBadge).animate_in).set_delay(.05)

			badge.size_flags_horizontal = Control.SizeFlags.SIZE_EXPAND_FILL
			add_child(badge)


func _draw() -> void:
	for child in get_children():
		(child as Control).custom_minimum_size.y = (child as Control).size.x


func animate_in() -> void:
	_pop_tween.play()


func focus_index(idx: int) -> void:
	var child := get_child(idx) as UiKetchupBadgeGridIcon
	child.grab_innie_focus.call()
