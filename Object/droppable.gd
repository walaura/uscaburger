extends RigidBody3D

@export var floor_collider: StaticBody3D

signal was_stacked(success: bool)

var drop_timer = Timer.new();
var speed_timer = Timer.new();

var is_hanging := true;

const MAX_OFFSET = 3;
const SPEED_TIMER_SPEED = 3;

func _ready() -> void:
	self.continuous_cd = true;
	self.mass = 0.1;
	self.position = Vector3(0,10,0);
	self.gravity_scale = 0;
	self.contact_monitor = true;
	self.max_contacts_reported = 1;
	
	var collider = self.get_child(1) as CollisionShape3D;
	var mesh = self.get_child(0) as MeshInstance3D;
	var box = BoxShape3D.new();
	box.size = mesh.get_aabb().size;
	
	self.add_child(drop_timer);
	self.add_child(speed_timer);
	
	self.body_entered.connect(on_body_entered)
	drop_timer.timeout.connect(on_time_out)
	drop_timer.one_shot = true;
	
	speed_timer.start(SPEED_TIMER_SPEED);

	collider.shape = box;
	print(collider);


func on_body_entered(body: Node3D):
	drop_timer.start(1);
	if(body == floor_collider):
		on_touch_floor()
	

func on_touch_floor():
	self.freeze = true
	drop_timer.stop()
	was_stacked.emit(false)

func on_time_out(): 
	self.freeze = true
	was_stacked.emit(true)

func _process(delta: float) -> void:	
	Dp.push('timer', floor(drop_timer.time_left*1000))
	Dp.push('offset', self.transform.basis.x)
		
	if Input.is_action_just_pressed("Drop"):
		is_hanging = false;
		self.gravity_scale = 1;
	
	if(is_hanging):
		var position_time_normal = speed_timer.time_left / SPEED_TIMER_SPEED;
		if(position_time_normal > .5):
			position_time_normal = 1 - position_time_normal;
		position_time_normal = (position_time_normal * 2);
		
		var posi = lerp(MAX_OFFSET * -1.0, MAX_OFFSET * +1.0, position_time_normal)
		self.position.x = posi

	pass
