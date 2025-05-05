extends Node3D

@export var is_filling: bool = false;

@onready var liquid: CSGMesh3D = %Liquid;
@onready var subtraction_box: CSGBox3D = %SubtractionBox;
@onready var area_3d: Area3D = %Area3D;

var max_pos_offset: float = .2;
var fill_speed: float = .1;
var sub_box_initial_pos_y: float;

func _ready() -> void:
	area_3d.area_entered.connect(_on_particle_enter);
	area_3d.area_exited.connect(_on_particle_exit);
	
	sub_box_initial_pos_y = subtraction_box.position.y;

func _process(delta: float) -> void:
	if not is_filling: return;
	fill_cup(delta);

func _on_particle_enter() -> void:
	is_filling = true;

func _on_particle_exit() -> void:
	is_filling = false;

func fill_cup(delta: float) -> void:
	if subtraction_box.position.y >= max_pos_offset: return;
	subtraction_box.position.y += delta * fill_speed;
