extends Node

@export var floor_collider: StaticBody3D
@export var aninm: Node3D

signal on_new_spawn(part: Variant)
signal on_game_over
var stack_height := 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_path()
	on_spawn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("DBG-Spawn"):
		on_spawn();


func on_spawn() -> void:
	var part = Parts.get_random_part() if stack_height > 0 else Parts.get_heel()
	part.set_script(load("res://Object/droppable.gd"))
	part.floor_collider = floor_collider;
	part.height = stack_height;
	part.was_stacked.connect(on_stack)
	add_child(part)
	on_new_spawn.emit(part)


func on_stack(is_success: bool, height) :
	Dp.push('stack', stack_height)
	if(!is_success):
		on_game_over.emit()
	else: 
		stack_height = height;
		on_spawn();
