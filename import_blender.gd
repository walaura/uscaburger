@tool
extends EditorScenePostImport

var maybe_collider: MeshInstance3D
var maybe_splat: MeshInstance3D
var rigidbody: RigidBody3D


func _post_import(scene: Node) -> Node:
	scene = iterate(scene)
	scene = iterate_wrapup(scene)
	return scene


# Assign stuff after ecverything is known
func iterate_wrapup(node: Node) -> Node:
	for child in node.get_children():
		if child is RigidBody3D and maybe_splat != null:
			(child as RigidBody3D).add_child(maybe_splat)
		if child is CollisionShape3D and maybe_collider != null:
			(child as CollisionShape3D).shape = maybe_collider.mesh.create_convex_shape()
		child = iterate_wrapup(child)
	return node


func iterate(node: Node) -> Node:
	for child in node.get_children():
		if child.name.begins_with('_collider'):
			maybe_collider = child
			node.remove_child(child)
		if child.name.begins_with('_splat'):
			(child as Node3D).visible = false
			maybe_splat = child
			node.remove_child(child)
		else:
			child = iterate(child)
	return node
