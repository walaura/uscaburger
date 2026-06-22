@tool
extends EditorScenePostImport

var maybe_collider: MeshInstance3D


func _post_import(scene: Node) -> Node:
	scene = iterate(scene)
	return scene


func iterate(node: Node) -> Node:
	for child in node.get_children():
		if child.name.contains('_collider':
			maybe_collider = child
			node.remove_child(child)
		if child is CollisionShape3D and maybe_collider != null:
			(child as CollisionShape3D).shape = maybe_collider.mesh.create_convex_shape()
		else:
			iterate(child)
	return node
