class_name SavedRecordIntResource
extends SavedRecordResource
var record: int


func _init(new_record: int, new_saved_at := Time.get_unix_time_from_system()) -> void:
	record = new_record
	super._init(new_saved_at)


func serialize() -> Dictionary:
	return {"record": record, "saved_at": saved_at}


static func deserialize(data: Dictionary) -> SavedRecordIntResource:
	if !data.has("record") or not data["record"] is int:
		return
	if !data.has("saved_at") or not data["saved_at"] is float:
		return

	@warning_ignore("UNSAFE_CAST")
	return SavedRecordIntResource.new(data["record"] as int, data["saved_at"] as float)
