extends Camera3D

var lerp_speed = 6
var offset = Vector3(10, 10, 10)

var og_transform = transform
var og_fov = fov


func get_camera_position_for_aabb(aabb: AABB) -> Vector3:
	# Get the largest size dimension of the AABB
	var size: float = max(aabb.size.x, max(aabb.size.y, aabb.size.z))

	# Calculate required distance
	var fov_rad: float = deg_to_rad(fov)
	var distance: float = (size / 2.0) / tan(fov_rad / 2.0)

	# Add a slight padding so the AABB does not touch the exact screen edge
	distance *= 1.5

	# Position the camera back from the center of the AABB
	var center: Vector3 = aabb.get_center()
	var view_dir: Vector3 = -global_transform.basis.z.normalized()

	return center - (view_dir * distance)


func _physics_process(delta):
	match Camera.mode:
		Camera.Mode.ZOOM_OUT:
			transform.origin = transform.origin.lerp(
				get_camera_position_for_aabb(Camera.ZOOM_OUT_AABB), lerp_speed * delta
			)

		Camera.Mode.GAMEPLAY:
			if !Camera.GAMEPLAY_target:
				return

			var target_fov = og_fov
			if (
				Camera.GAMEPLAY_dramatic_timer_zoom != 1.0
				&& Camera.GAMEPLAY_dramatic_timer_zoom != 0.0
			):
				target_fov = target_fov - 30 + (30 * Camera.GAMEPLAY_dramatic_timer_zoom)

			fov = move_toward(fov, target_fov, delta * lerp_speed)

			# Calculate the final desired transform
			var target_transform = transform.looking_at(
				Vector3(0.2, 1, 1) * (Camera.GAMEPLAY_target.global_position - Vector3(-4, 1, 0)),
				Vector3.UP
			)

			# Smoothly interpolate (Slerp) the camera's current rotation to the new rotation
			basis = basis.slerp(target_transform.basis, lerp_speed * delta)
			transform.origin = transform.origin.lerp(
				Vector3(1, Camera.GAMEPLAY_target.global_position.y + 2, 8), lerp_speed * delta
			)
