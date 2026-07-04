class_name SavedRecordIntResource
extends SavedRecordResource
var record: int


func _init(new_record: int, new_saved_at := Time.get_unix_time_from_system()) -> void:
	record = new_record
	super._init(new_saved_at)
