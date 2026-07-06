extends Node

var score := CurrentRun_Score.new()
var inventory := CurrentRun_Inventory.new()

var player_data := RsPlayerData.new()
var _preloader := Loader.new()

signal on_run_start


func _ready() -> void:
	#_fake_startup_data()
	for item in CurrentRun_Inventory._get_all_items():
		_preloader.queue_resource(CurrentRun_Inventory._get_item_path(item))
	on_run_start.emit()


func start_new_run() -> void:
	score = CurrentRun_Score.new()
	inventory = CurrentRun_Inventory.new()
	on_run_start.emit()


func _fake_startup_data() -> void:
	var tallest := RsBurgerStats.new()
	tallest.height = 270.8
	tallest.length = 40
	tallest.price = 8967
	score.finalize_burger(tallest)
	var longest := RsBurgerStats.new()
	longest.height = 7.8
	longest.length = 900
	longest.price = 8967
	score.finalize_burger(longest)
	var failed := RsFailedBurgerStats.new()
	score.finalize_burger(failed)
	var priciest := RsBurgerStats.new()
	priciest.height = 1.8
	priciest.length = 20
	priciest.price = 18967
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
	score.finalize_burger(priciest)
