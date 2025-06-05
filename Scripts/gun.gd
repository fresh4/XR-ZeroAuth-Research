extends Node3D

const BALL = preload("res://Prefabs/ball_projectile.tscn");

@export var fire_delay: float = 2.0;
@export var fire_force: float = 5.0;
@export var fire_angles: Array[Node3D] = []

@onready var fire_origin: Node3D = %FireOrigin

var is_test_active: bool = false;
var balls_launched_num: int = 0;
var timer: Timer;

func _ready() -> void:
	timer = Timer.new();
	timer.wait_time = fire_delay;
	timer.one_shot = true;
	add_child(timer)

func _input(event: InputEvent) -> void:
	if event.is_action_released("start_projectiles_test"):
		is_test_active = !is_test_active;

func _process(_delta: float) -> void:
	if not is_test_active: return;
	if not timer.is_stopped(): return;
	timer.start()
	# FIRE!
	var ball: RigidBody3D = BALL.instantiate();
	ball.name = "Projectile" + str(balls_launched_num)
	fire_origin.add_child(ball);
	
	# Apply impulse to ball at certain angle to launch it at player
	var direction = global_position.direction_to(fire_angles[balls_launched_num].global_position)
	ball.apply_impulse(direction * fire_force);
	
	# Automatically check if balls launched = len of angles array and set active to false
	balls_launched_num += 1;
	if balls_launched_num >= len(fire_angles): 
		#is_test_active = false;
		balls_launched_num = 0;
	await timer.timeout;
	ball.queue_free();
