extends Node

var score := CurrentRun_Score.new()
var inventory := CurrentRun_Inventory.new()

var player_data := RsPlayerData.new()

signal on_run_start


func _ready() -> void:
	on_run_start.emit()


func start_new_run() -> void:
	score = CurrentRun_Score.new()
	inventory = CurrentRun_Inventory.new()
	on_run_start.emit()
