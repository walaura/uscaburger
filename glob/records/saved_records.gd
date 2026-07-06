extends Node

const CONFIG_FILE := "user://records.cfg"

var config := ConfigFile.new()
var records := SavedRecordsResource.new()

signal on_config_changed


func _init() -> void:
	var err := config.load(CONFIG_FILE)

	if err != OK:
		printerr("oopsies")
		save()
		return

	var value: Variant = config.get_value("x", "x", SavedRecordsResource.new().serialize())
	if value is Dictionary:
		var _vl: Dictionary = value
		records = SavedRecordsResource.deserialize(_vl)
	else:
		printerr("Serialization is fucked")
		records = SavedRecordsResource.new()


func save() -> void:
	config.set_value("x", "x", records.serialize())
	config.save(CONFIG_FILE)
	on_config_changed.emit()


func delete_HEY_THIS_IS_DANGEROUS() -> void:
	config.clear()
	config.save(CONFIG_FILE)
	_init.call_deferred()
