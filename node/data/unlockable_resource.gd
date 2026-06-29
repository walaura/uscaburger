@tool
class_name RsUnlockable
extends Resource

@export_multiline var name: String
@export var icon: CompressedTexture2D
@export_multiline var desc: String
@export var price: int

## wont show up without these
@export var requires: Array[StringName]

@export_group("Incremental stuffs")
@export var is_incremental: bool
@export var incremental_mult: float
@export var incremental_value: float
@export var incremental_extra_names: Array[String]
@export var incremental_extra_icons: Array[CompressedTexture2D]
@export var incremental_modulo_at: int = -1

@warning_ignore_start("unused_private_class_variable")
@export_group("Secret sys stuff")
@export_range(1, 1, 1) var _tier: int = 1
@export var _path: String
