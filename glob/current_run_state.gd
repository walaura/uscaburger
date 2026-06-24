extends Node

var score_handler := CurrentRunState_Score.new()
var inventory_handler := CurrentRunState_Inventory.new()

var player_data := PlayerDataResource.new()

signal on_run_start


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	on_run_start.emit()


func start_new_run() -> void:
	score_handler = CurrentRunState_Score.new()
	inventory_handler = CurrentRunState_Inventory.new()
	on_run_start.emit()
