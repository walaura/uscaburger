class_name SavedRecordFloatResource
extends SavedRecordResource
var record: float


func _init(new_record: float, new_saved_at := Time.get_unix_time_from_system()) -> void:
	record = new_record
	super._init(new_saved_at)
