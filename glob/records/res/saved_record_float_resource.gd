class_name SavedRecordFloatResource
extends SavedRecordResource
var record: float


func _init(new_record: float, new_saved_at := Time.get_unix_time_from_system()) -> void:
	record = new_record
	super._init(new_saved_at)


func serialize() -> Dictionary:
	return {"record": record, "saved_at": saved_at}


static func deserialize(data: Dictionary) -> SavedRecordFloatResource:
	if !data.has("record") or not data["record"] is float:
		return
	if !data.has("saved_at") or not data["saved_at"] is float:
		return

	@warning_ignore("UNSAFE_CAST")
	return SavedRecordFloatResource.new(data["record"] as float, data["saved_at"] as float)
