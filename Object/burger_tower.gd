extends Node

@export var floor_collider: StaticBody3D
@export var aninm: Node3D

static var SCORE_OVERLAY_SCN = preload("res://object/ui/score_overlay.tscn");

signal on_new_spawn(part: Variant)
signal on_game_over
var stack_height := 0.0;

var last_valid_part_in_stack: CollisionShape3D;
var part: RigidBody3D;
var score_overlay: Control;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_path()
	on_spawn()
	
	score_overlay = SCORE_OVERLAY_SCN.instantiate() as Control;
	#score_overlay.position = Vector2(INF, INF)
	add_child(score_overlay);


func _physics_process(delta):
	if(last_valid_part_in_stack):
		var camera = get_viewport().get_camera_3d()
		var center3d = last_valid_part_in_stack.global_position + Vector3.RIGHT;
		var center2d = camera.unproject_position(center3d) - Vector2(0,score_overlay.size.y)
		score_overlay.position = score_overlay.position.lerp(center2d, delta * 10)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("DBG-Spawn"):
		on_spawn();


func on_spawn() -> void:
	if(part):
		for child in part.get_children():
			if child is CollisionShape3D:
				# You found your mesh!
				print("Found mesh: ", child.name)
				last_valid_part_in_stack = child;
		
	Dp.push('pt',last_valid_part_in_stack)
	
	part = Parts.get_random_part() if stack_height > 0 else Parts.get_heel()
	part.set_script(load("res://Object/droppable.gd"))
	part.floor_collider = floor_collider;
	part.height = stack_height;
	part.was_stacked.connect(on_stack)
	add_child(part)
	on_new_spawn.emit(part)


func on_stack(is_success: bool, height) :
	Dp.push('stack', stack_height)
	if(!is_success):
		score_overlay.push('U DIED')
		on_game_over.emit()
	else: 
		score_overlay.push('item')
		stack_height = height;
		on_spawn();
