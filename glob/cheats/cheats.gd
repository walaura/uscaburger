extends Node

const FAKE_SIGNAL = Signal()


func with_container(
	cat: StringName,
	setup_callback: Callable,
	maybe_exit_tree: Signal = FAKE_SIGNAL,
) -> void:
	var maybe_container := %Tools.get_node_or_null("CtT" + cat) as FoldableContainer
	var maybe_guts := (maybe_container.get_child(0) as VBoxContainer) if maybe_container != null else null

	if maybe_guts:
		for n in maybe_guts.get_children():
			maybe_guts.remove_child(n)
			n.queue_free()
	else:
		maybe_container = FoldableContainer.new()
		maybe_container.name = "CtT" + cat
		maybe_container.unique_name_in_owner = true
		maybe_container.title = cat

		maybe_guts = VBoxContainer.new()
		maybe_container.add_child(maybe_guts)
		%Tools.add_child(maybe_container)

	setup_callback.call_deferred(maybe_guts)

	if maybe_exit_tree != FAKE_SIGNAL:
		maybe_exit_tree.connect(
			func() -> void:
				%Tools.remove_child(maybe_container)
				maybe_container.queue_free()
		)
