extends Node

var config := ConfigFile.new()
var records := SavedRecordsResource.new()

signal on_config_changed


func _init() -> void:
	var err := config.load("user://records.cfg")

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
	config.save("user://records.cfg")
	on_config_changed.emit()
