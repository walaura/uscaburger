@abstract class_name RsBaseItem
extends Resource

@export_multiline var name: String
@export var icon: CompressedTexture2D
@export_multiline var desc: String
## Shows in the run totals as the multplier
@export_multiline var fx_short_desc: String
@export var price: int

@export_group("Incremental stuffs")
@export var incremental_value: float


func get_key() -> String:
	return resource_path.get_file()
