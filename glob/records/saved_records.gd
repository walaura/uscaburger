extends Node

var config := ConfigFile.new()
signal on_config_changed


func _init() -> void:
	var err := config.load("user://gfx.cfg")

	if err != OK:
		printerr("oopsies")
		return


func _ready() -> void:
	for key in config.get_section_keys("gfx"):
		var value: Variant = config.get_value("gfx", key)
		@warning_ignore("unsafe_call_argument")
		#apply_gfx_setting(int(key), value)


func _save() -> void:
	config.save("user://gfx.cfg")
	on_config_changed.emit()
