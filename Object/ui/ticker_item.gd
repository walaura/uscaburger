extends HBoxContainer

var anim_lib: AnimationLibrary = preload("res://asset/animations.res")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false;
	pass # Replace with function body.

func push(title: String, price: int) -> void:
	var player = AnimationPlayer.new()
	self.add_child(player)
	player.add_animation_library('animations',anim_lib)
	player.play("animations/pop");
	player.seek(0)

	visible = true;
	(get_child(0) as Label).text = title;
	(get_child(1) as Label).text = '$' + ("%.2f" % (price/100.0));
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
