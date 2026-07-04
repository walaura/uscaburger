@abstract class_name SavedRecordResource
extends SerializableResource
var saved_at: float


func _init(new_saved_at := Time.get_unix_time_from_system()) -> void:
	saved_at = new_saved_at
