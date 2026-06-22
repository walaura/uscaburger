extends Node2D

class_name VisibleOnDev

func _init() -> void:
	visible = Helper.is_debug


func _process(_delta: float) -> void:
	visible = Helper.is_debug
