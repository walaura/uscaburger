class_name RsPart
extends Resource

@export var price: int
@export var name: String
@export var model: PackedScene

@export_group("Flags")
@export var is_heel := false
@export var is_crown := false
@export var is_sauce := false
@export var is_patty := false
@export var is_meat := false
@export var requires_upgrade: RsUnlockable
