@tool
class_name RsDifficultyNumbersViz
extends EditorScript

@export_tool_button("Hello", "Callable") var hello_action := _run


func _run() -> void:
	print("RsDifficultyNumbers Visualization")
	print("================================================")

	var viz_resource := RsDifficultyNumbers.new()

	# Print initial values
	print("Initial state:")
	print("Wave speed timer: %.6f" % viz_resource.wave_speed_timer_speed)
	print("Wave max offset: %.6f" % viz_resource.wave_max_offset)
	print()

	# Call on_successful_stack 100 times and print results
	print("Executing 100 consecutive on_successful_stack() calls:")
	print("--------------------------------------------------------")
	print("Stack | Wave Speed Timer | Wave Max Offset")
	print("--------|------------------|---------------")

	# Print initial state
	print(
		"%5d | %16.6f | %13.6f" % [0, viz_resource.wave_speed_timer_speed, viz_resource.wave_max_offset],
	)

	for i in range(1, 101):
		viz_resource.on_successful_stack()

		if i <= 10 or i % 10 == 0:  # Print first 10 and every 10th
			print(
				"%5d | %16.6f | %13.6f" % [i, viz_resource.wave_speed_timer_speed, viz_resource.wave_max_offset],
			)
