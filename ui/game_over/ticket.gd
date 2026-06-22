@tool
extends PanelContainer

func _process(_delta: float) -> void:
	material.set('shader_parameter/AspectRatio', self.size.x / self.size.y)
