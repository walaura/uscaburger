class_name RsUnlockableWTier
extends RsUnlockableBase

@export var og: RsUnlockable
@export var tier: int = 1


func get_key() -> String:
	return og.resource_path.get_file()
