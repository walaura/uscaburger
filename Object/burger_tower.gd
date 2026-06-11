extends Node

@export var parts_scene: PackedScene
@export var floor_collider: StaticBody3D

signal on_new_spawn(part: Variant)
signal on_game_over
var stack_height := 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	on_spawn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("DBG-Spawn"):
		on_spawn();


func on_spawn() -> void:
	var parts = parts_scene.instantiate();
	var part = parts.get_node("Heel").duplicate() as RigidBody3D;
	part.set_script(load("res://Object/droppable.gd"))
	part.floor_collider = floor_collider;
	part.was_stacked.connect(on_stack)
	add_child(part)
	on_new_spawn.emit(part)


func on_stack(is_success: bool) :
	Dp.push('stack', stack_height)
	print(is_success);
	if(!is_success):
		on_game_over.emit()
	else: 
		stack_height += 1;
		on_spawn();
