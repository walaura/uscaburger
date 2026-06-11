extends Node
#class_name Dp

const DP_ROW = preload("res://addons/godot-debug-panel/dp_row.tscn")

@onready var _container: HFlowContainer = $Container

var _data: Dictionary[StringName, Label]


## Debug panel visibilty.
@export var visible := true :
	set(v):
		visible = v
		if is_node_ready():
			_container.visible = v


func _ready() -> void:
	_container.visible = visible


## Insert or update row by id with provided value.
func push(id: StringName, value: Variant) -> void:
	var label := _data.get(id)
	
	if label == null:
		var row := DP_ROW.instantiate()
		
		var row_name := str(id)
		
		_container.add_child(row)
		row.name = row_name
		
		var title_label: Label = row.get_node("%Title")
		var value_label: Label = row.get_node("%Value")
		
		title_label.text = "%s:" % row_name
		
		_data[id] = value_label
		label = value_label
	
	label.text = str(value)


## Remove row by id.
func erase(id: StringName) -> void:
	if not _data.has(id):
		push_warning("Dp.erase Row %s doesn't exit" % id)
		return
	
	_container.get_node(NodePath(id)).queue_free()
	_data.erase(id)


## Hide row by id.
func hide(id: StringName) -> void:
	if not _data.has(id):
		push_warning("Dp.hide Row %s doesn't exit" % id)
		return
	
	_container.get_node(NodePath(id)).hide()


## Show row by id.
func show(id: StringName) -> void:
	_container.get_node(NodePath(id)).show()


## Remove all rows.
func clear() -> void:
	for c in _container.get_children():
		c.queue_free()
	_data.clear()
