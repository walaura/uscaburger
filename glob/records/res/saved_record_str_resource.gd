class_name SavedRecordStrResource
extends SavedRecordResource
var record: String


func _init(new_record: String, new_saved_at := Time.get_unix_time_from_system()) -> void:
	record = new_record
	super._init(new_saved_at)


func serialize() -> Dictionary:
	return {"record": record, "saved_at": saved_at}


static func deserialize(data: Dictionary) -> SavedRecordStrResource:
	if !data.has("record") or not data["record"] is String:
		return
	if !data.has("saved_at") or not data["saved_at"] is float:
		return

	@warning_ignore("UNSAFE_CAST")
	return SavedRecordStrResource.new(data["record"] as String, data["saved_at"] as float)
