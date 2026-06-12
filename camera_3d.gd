extends Camera3D

@export var lerp_speed = 3
@export var target: Node3D
@export var offset = Vector3(10,10,10)

func _physics_process(delta):
	if !target:
		return

	# Calculate the final desired transform
	var target_transform = transform.looking_at(target.global_position - Vector3(0,.5,0), Vector3.UP) 
	
	# Smoothly interpolate (Slerp) the camera's current rotation to the new rotation
	basis = basis.slerp(target_transform.basis, lerp_speed * delta)
	transform.origin = transform.origin.lerp(Vector3(0,target.transform.origin.y + 4, 8), lerp_speed*delta)
