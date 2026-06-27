class_name CurrentRunState_ScoreLineItemResource
extends Resource

@export var value: int = 0
@export var explanation: String = ""

@export var is_total: bool = false


func _init(
	nw_explanation: String,
	nw_value: int,
	nw_is_total: bool = false,
) -> void:
	value = nw_value
	explanation = nw_explanation
	is_total = nw_is_total
