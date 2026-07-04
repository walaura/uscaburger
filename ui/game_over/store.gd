class_name UiGameOver_Store
extends Control

@onready var STORE_PRODUCT_SCN := preload("res://ui/game_over/store/store_product.tscn")
var disabled := false:
	set(val):
		disabled = val
		if not is_node_ready():
			await ready
		_set_disabled()

signal on_purchase(product: RsItem)


func on_reroll() -> void:
	_on_reroll()


func _ready() -> void:
	_on_reroll()


func _set_disabled() -> void:
	focus_behavior_recursive = (
		Control.FocusBehaviorRecursive.FOCUS_BEHAVIOR_DISABLED if disabled else Control.FocusBehaviorRecursive.FOCUS_BEHAVIOR_INHERITED
	)
	mouse_behavior_recursive = (
		Control.MouseBehaviorRecursive.MOUSE_BEHAVIOR_DISABLED if disabled else Control.MouseBehaviorRecursive.MOUSE_BEHAVIOR_INHERITED
	)


func _on_reroll() -> void:
	var all_items := CurrentRun.inventory.get_purchasable_items()
	var all_affordables := all_items.filter(CurrentRun.inventory.is_affordable) as Array[RsItem]
	var all_rest := all_items.filter(CurrentRun.inventory.is_unaffordable) as Array[RsItem]
	var pick: Array[RsItem] = []

	var affordables_count := 0
	for index in range(0, 3):
		# Show at least 2 affordables if possible
		if !all_affordables.is_empty() && affordables_count < 2:
			# boost non incrementals on slot 0
			if affordables_count == 0:
				var maybe_non_seq := all_affordables.find_custom(CurrentRun.inventory.is_nonincremental)
				if maybe_non_seq >= 0:
					pick.push_back(all_affordables[maybe_non_seq])
					all_affordables.remove_at(maybe_non_seq)
				else:
					pick.push_back(all_affordables.pop_back())
			else:
				pick.push_back(all_affordables.pop_back())
			affordables_count += 1

		# if EVERYTHING is affordable, toss one more in
		elif !all_affordables.is_empty() && all_rest.is_empty():
			pick.push_back(all_affordables.pop_back())

		# Push 1 unaffordable for motivation
		else:
			pick.push_back(all_rest.pop_back())

	pick.shuffle()

	for child in %StoreRoot.get_children():
		%StoreRoot.remove_child(child)
		child.queue_free()
	for unlockable_cp in pick:
		var store_product_scn: UiGameOver_StoreProduct = STORE_PRODUCT_SCN.instantiate()
		store_product_scn.product = unlockable_cp
		store_product_scn.on_purchase_pressed.connect(func() -> void: on_purchase.emit(unlockable_cp))

		%StoreRoot.add_child(store_product_scn)
