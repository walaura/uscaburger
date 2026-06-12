extends RigidBody3D

@export var floor_collider: StaticBody3D
@export var height := 0

signal was_stacked(success: bool, height: float)

var drop_timer = Timer.new();
var speed_timer = Timer.new();
var anim_lib: AnimationLibrary = preload("res://asset/animations.res")

var is_hanging := true;

const MAX_OFFSET = 2;
const SPEED_TIMER_SPEED = 3;

func _ready() -> void:
	self.continuous_cd = true;
	self.mass = 5;
	self.position = Vector3(0, height+2, 0) + (Vector3.RIGHT * -MAX_OFFSET);
	self.gravity_scale = 0;
	self.contact_monitor = true;
	self.max_contacts_reported = 1;
	
	self.add_child(drop_timer);
	self.add_child(speed_timer);
	
	
	var player = AnimationPlayer.new()
	self.add_child(player)
	player.add_animation_library('animations',anim_lib)
	player.play("animations/pop");
	player.seek(0)

	
	self.body_entered.connect(on_body_entered)
	drop_timer.timeout.connect(on_time_out)
	drop_timer.one_shot = true;
	speed_timer.start(SPEED_TIMER_SPEED);


func on_body_entered(body: Node3D):
	drop_timer.start(1);
	if(body == floor_collider):
		on_touch_floor()
	
func on_touch_floor():
	self.freeze = true
	drop_timer.stop()
	was_stacked.emit(false, position.y)

func on_time_out(): 
	self.freeze = true
	was_stacked.emit(true, self.position.y)
	
func sling_sideways():
	if(self.freeze):
		return
	var position_time_normal = speed_timer.time_left / SPEED_TIMER_SPEED;
	if(position_time_normal > .5):
		position_time_normal = 1 - position_time_normal;
	position_time_normal = (position_time_normal * 2);
	
	var posi = lerp(MAX_OFFSET * -1.0, MAX_OFFSET * +1.0, position_time_normal)
	self.position.x = posi

func _process(delta: float) -> void:	
	if Input.is_action_just_pressed("Drop"):
		is_hanging = false;
		self.gravity_scale = 1;
	
	if(is_hanging):
		sling_sideways()

	pass
