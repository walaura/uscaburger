extends RigidBody3D

@export var mesh_node: MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func wrap_mesh_with_box(body_node: CollisionObject3D) -> void:
	# 1. Fetch the local space bounding box boundaries
	var aabb: AABB = mesh_node.get_aabb()
	
	# 2. Instantiate physics structure nodes
	var collision_shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	
	# 3. Match dimensions explicitly 
	box_shape.size = aabb.size
	collision_shape.shape = box_shape
	
	# 4. Offset center to match mesh pivot shifts
	collision_shape.position = mesh_node.position + aabb.get_center()
	
	# 5. Append to your physics object hierarchy
	add_child(collision_shape)
