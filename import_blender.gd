@tool # Needed so it runs in editor.
extends EditorScenePostImport

# This sample changes all node names.
# Called right after the scene is imported and gets the root node.
func _post_import(scene):
	for child in scene.get_children():
		iterate(child)
	return scene 

func iterate( node: Node):
	return node;
